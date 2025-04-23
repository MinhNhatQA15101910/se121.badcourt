using CourtService.Core.Domain.Entities;
using CourtService.Core.Domain.Repositories;
using CourtService.Infrastructure.Configuration;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace CourtService.Infrastructure.Persistence.Repositories;

public class CourtRepository : ICourtRepository
{
    private readonly IMongoCollection<Court> _courts;

    public CourtRepository(
        IOptions<CourtDatabaseSettings> courtDatabaseSettings
    )
    {
        var mongoClient = new MongoClient(courtDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(courtDatabaseSettings.Value.DatabaseName);
        _courts = mongoDatabase.GetCollection<Court>(courtDatabaseSettings.Value.CourtsCollectionName);
    }

    public async Task AddCourtAsync(Court court, CancellationToken cancellationToken = default)
    {
        await _courts.InsertOneAsync(court, cancellationToken: cancellationToken);
    }

    public Task<bool> AnyAsync(CancellationToken cancellationToken = default)
    {
        return _courts.Find(_ => true).AnyAsync(cancellationToken: cancellationToken);
    }

    public async Task<Court?> GetCourtByIdAsync(string id, CancellationToken cancellationToken = default)
    {
        return await _courts.Find(court => court.Id == id).FirstOrDefaultAsync(cancellationToken: cancellationToken);
    }
}
