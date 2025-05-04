using AutoMapper;
using CourtService.Core.Domain.Entities;
using CourtService.Core.Domain.Repositories;
using CourtService.Infrastructure.Configuration;
using Microsoft.Extensions.Options;
using MongoDB.Bson;
using MongoDB.Driver;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace CourtService.Infrastructure.Persistence.Repositories;

public class CourtRepository : ICourtRepository
{
    private readonly IMongoCollection<Court> _courts;
    private readonly IMapper _mapper;

    public CourtRepository(
        IOptions<CourtDatabaseSettings> courtDatabaseSettings,
        IMapper mapper
    )
    {
        var mongoClient = new MongoClient(courtDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(courtDatabaseSettings.Value.DatabaseName);
        _courts = mongoDatabase.GetCollection<Court>(courtDatabaseSettings.Value.CourtsCollectionName);

        _mapper = mapper;
    }

    public async Task AddCourtAsync(Court court, CancellationToken cancellationToken = default)
    {
        await _courts.InsertOneAsync(court, cancellationToken: cancellationToken);
    }

    public async Task<bool> AnyAsync(CancellationToken cancellationToken = default)
    {
        return await _courts.Find(_ => true).AnyAsync(cancellationToken: cancellationToken);
    }

    public async Task<Court?> GetCourtByIdAsync(string id, CancellationToken cancellationToken = default)
    {
        return await _courts.Find(court => court.Id == id).FirstOrDefaultAsync(cancellationToken: cancellationToken);
    }

    public async Task<Court?> GetCourtByNameAsync(string courtName, string facilityId, CancellationToken cancellationToken = default)
    {
        return await _courts.Find(
            court => court.CourtName == courtName && 
            court.FacilityId == facilityId
        ).FirstOrDefaultAsync(cancellationToken: cancellationToken);
    }

    public async Task<PagedList<CourtDto>> GetCourtsAsync(CourtParams courtParams, CancellationToken cancellationToken = default)
    {
        var pipeline = new List<BsonDocument>();

        switch (courtParams.OrderBy)
        {
            case "courtName":
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("CourtName", courtParams.SortBy == "asc" ? 1 : -1)));
                break;
            case "registeredAt":
            default:
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("RegisteredAt", courtParams.SortBy == "asc" ? 1 : -1)));
                break;
        }

        // Filter by facility id
        if (!string.IsNullOrEmpty(courtParams.FacilityId))
        {
            pipeline.Add(new BsonDocument("$match", new BsonDocument("FacilityId", courtParams.FacilityId)));
        }

        var courts = await PagedList<Court>.CreateAsync(
            _courts,
            pipeline,
            courtParams.PageNumber,
            courtParams.PageSize,
            cancellationToken
        );

        return PagedList<CourtDto>.Map(courts, _mapper);
    }
}
