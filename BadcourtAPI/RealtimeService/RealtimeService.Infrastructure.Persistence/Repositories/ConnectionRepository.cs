using AutoMapper;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;

namespace RealtimeService.Infrastructure.Persistence.Repositories;

public class ConnectionRepository : IConnectionRepository
{
    private readonly IMongoCollection<Connection> _connections;
    private readonly IMapper _mapper;

    public ConnectionRepository(
        IOptions<RealtimeDatabaseSettings> realtimeDatabaseSettings,
        IMapper mapper
    )
    {
        var mongoClient = new MongoClient(realtimeDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(realtimeDatabaseSettings.Value.DatabaseName);
        _connections = mongoDatabase.GetCollection<Connection>(realtimeDatabaseSettings.Value.ConnectionsCollectionName);

        _mapper = mapper;
    }

    public async Task AddConnectionAsync(Connection connection, CancellationToken cancellationToken = default)
    {
        await _connections.InsertOneAsync(connection, cancellationToken: cancellationToken);
    }

    public async Task DeleteAllAsync(CancellationToken cancellationToken = default)
    {
        await _connections.DeleteManyAsync(
            Builders<Connection>.Filter.Empty,
            cancellationToken: cancellationToken
        );
    }

    public async Task DeleteConnectionAsync(string connectionId, CancellationToken cancellationToken = default)
    {
        await _connections.DeleteOneAsync(
            c => c.ConnectionId == connectionId,
            cancellationToken: cancellationToken
        );
    }

    public async Task<Connection?> GetConnectionByIdAsync(string connectionId, CancellationToken cancellationToken = default)
    {
        return await _connections
            .Find(c => c.ConnectionId == connectionId)
            .FirstOrDefaultAsync(cancellationToken: cancellationToken);
    }
}
