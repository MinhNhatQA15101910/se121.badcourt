using AutoMapper;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;

namespace RealtimeService.Infrastructure.Persistence.Repositories;

public class GroupRepository : IGroupRepository
{
    private readonly IMongoCollection<Group> _groups;
    private readonly IMapper _mapper;

    public GroupRepository(
        IOptions<RealtimeDatabaseSettings> realtimeDatabaseSettings,
        IMapper mapper
    )
    {
        var mongoClient = new MongoClient(realtimeDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(realtimeDatabaseSettings.Value.DatabaseName);
        _groups = mongoDatabase.GetCollection<Group>(realtimeDatabaseSettings.Value.GroupsCollectionName);

        _mapper = mapper;
    }

    public async Task AddGroupAsync(Group group, CancellationToken cancellationToken = default)
    {
        await _groups.InsertOneAsync(group, cancellationToken: cancellationToken);
    }

    public async Task<Group?> GetGroupByNameAsync(string groupName, CancellationToken cancellationToken = default)
    {
        return await _groups
            .Find(g => g.Name == groupName)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task UpdateGroupAsync(Group group, CancellationToken cancellationToken = default)
    {
        await _groups.ReplaceOneAsync(
            g => g.Id == group.Id,
            group,
            cancellationToken: cancellationToken
        );
    }
}
