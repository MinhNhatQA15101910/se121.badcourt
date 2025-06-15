using Microsoft.Extensions.Options;
using MongoDB.Driver;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;

namespace RealtimeService.Infrastructure.Persistence.Repositories;

public class CourtRepository : ICourtRepository
{
    private readonly IMongoCollection<Court> _courts;

    public CourtRepository(
        IOptions<RealtimeDatabaseSettings> realtimeDatabaseSettings
    )
    {
        var mongoClient = new MongoClient(realtimeDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(realtimeDatabaseSettings.Value.DatabaseName);
        _courts = mongoDatabase.GetCollection<Court>(realtimeDatabaseSettings.Value.CourtsCollectionName);
    }

    public async Task AddCourtAsync(Court court, CancellationToken cancellationToken = default)
    {
        await _courts.InsertOneAsync(court, cancellationToken: cancellationToken);
    }

    public async Task<bool> AnyAsync(CancellationToken cancellationToken = default)
    {
        return await _courts
            .Find(Builders<Court>.Filter.Empty)
            .AnyAsync(cancellationToken: cancellationToken);
    }

    public async Task<Court?> GetCourtByIdAsync(string courtId, CancellationToken cancellationToken = default)
    {
        return await _courts
            .Find(c => c.Id == courtId)
            .FirstOrDefaultAsync(cancellationToken: cancellationToken);
    }
}
