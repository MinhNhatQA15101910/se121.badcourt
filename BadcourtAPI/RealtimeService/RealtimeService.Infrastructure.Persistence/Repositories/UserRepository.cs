using Microsoft.Extensions.Options;
using MongoDB.Driver;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;

namespace RealtimeService.Infrastructure.Persistence.Repositories;

public class UserRepository : IUserRepository
{
    private readonly IMongoCollection<User> _users;

    public UserRepository(
        IOptions<RealtimeDatabaseSettings> realtimeDatabaseSettings
    )
    {
        var mongoClient = new MongoClient(realtimeDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(realtimeDatabaseSettings.Value.DatabaseName);
        _users = mongoDatabase.GetCollection<User>(realtimeDatabaseSettings.Value.UsersCollectionName);
    }

    public async Task AddUserAsync(User user, CancellationToken cancellationToken = default)
    {
        await _users.InsertOneAsync(user, cancellationToken: cancellationToken);
    }

    public async Task<bool> AnyAsync(CancellationToken cancellationToken = default)
    {
        return await _users.Find(_ => true).AnyAsync(cancellationToken);
    }
}
