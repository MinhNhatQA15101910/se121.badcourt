using AutoMapper;
using CourtService.Core.Domain.Entities;
using CourtService.Core.Domain.Repositories;
using CourtService.Infrastructure.Configuration;
using Microsoft.EntityFrameworkCore;
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

    public async Task<decimal> GetFacilityMaxPriceAsync(string facilityId, CancellationToken cancellationToken = default)
    {
        var filter = new BsonDocument("FacilityId", facilityId);
        var pipeline = new[]
        {
            new BsonDocument("$match", filter),
            new BsonDocument("$group", new BsonDocument
            {
                { "_id", BsonNull.Value },
                { "maxPrice", new BsonDocument("$max", "$PricePerHour") }
            })
        };

        var result = await _courts.AggregateAsync<BsonDocument>(pipeline, cancellationToken: cancellationToken);
        var document = await result.FirstOrDefaultAsync(cancellationToken);

        decimal maxPrice = 0;
        if (document != null && document.Contains("maxPrice") && document["maxPrice"].IsDecimal128)
        {
            maxPrice = document["maxPrice"].ToDecimal();
        }

        return maxPrice;
    }

    public async Task<decimal> GetFacilityMinPriceAsync(string facilityId, CancellationToken cancellationToken = default)
    {
        var filter = new BsonDocument("FacilityId", facilityId);
        var pipeline = new[]
        {
            new BsonDocument("$match", filter),
            new BsonDocument("$group", new BsonDocument
            {
                { "_id", BsonNull.Value },
                { "minPrice", new BsonDocument("$min", "$PricePerHour") }
            })
        };

        var result = await _courts.AggregateAsync<BsonDocument>(pipeline, cancellationToken: cancellationToken);
        var document = await result.FirstOrDefaultAsync(cancellationToken);

        decimal minPrice = 0;
        if (document != null && document.Contains("minPrice") && document["minPrice"].IsDecimal128)
        {
            minPrice = document["minPrice"].ToDecimal();
        }

        return minPrice;
    }

    public async Task<int> GetTotalCourtsAsync(string? userId, ManagerDashboardSummaryParams @params, CancellationToken cancellationToken)
    {
        var filter = Builders<Court>.Filter.Empty;

        if (!string.IsNullOrEmpty(userId))
        {
            filter = Builders<Court>.Filter.Eq(c => c.UserId, userId);
        }

        // Filter by year
        if (@params.Year.HasValue)
        {
            var startDate = new DateTime(@params.Year.Value, 1, 1);
            var endDate = new DateTime(@params.Year.Value, 12, 31, 23, 59, 59);
            filter &= Builders<Court>.Filter.And(
                Builders<Court>.Filter.Gte(c => c.CreatedAt, startDate),
                Builders<Court>.Filter.Lte(c => c.CreatedAt, endDate)
            );
        }

        return (int)await _courts.CountDocumentsAsync(filter, cancellationToken: cancellationToken);
    }

    public async Task UpdateCourtAsync(Court court, CancellationToken cancellationToken = default)
    {
        await _courts.ReplaceOneAsync(c => c.Id == court.Id, court, cancellationToken: cancellationToken);
    }
}
