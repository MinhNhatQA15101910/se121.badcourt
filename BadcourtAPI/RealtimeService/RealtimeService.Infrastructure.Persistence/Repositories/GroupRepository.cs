using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Infrastructure.Persistence.Repositories;

public class GroupRepository : IGroupRepository
{
    private readonly IMongoCollection<Group> _groups;
    private readonly IMongoCollection<Connection> _connections;
    private readonly IMapper _mapper;

    public GroupRepository(
        IOptions<RealtimeDatabaseSettings> realtimeDatabaseSettings,
        IMapper mapper
    )
    {
        var mongoClient = new MongoClient(realtimeDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(realtimeDatabaseSettings.Value.DatabaseName);
        _groups = mongoDatabase.GetCollection<Group>(realtimeDatabaseSettings.Value.GroupsCollectionName);
        _connections = mongoDatabase.GetCollection<Connection>(realtimeDatabaseSettings.Value.ConnectionsCollectionName);

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

    public async Task<Group?> GetGroupForConnectionAsync(string connectionId, CancellationToken cancellationToken = default)
    {
        var connection = await _connections
            .Find(c => c.ConnectionId == connectionId)
            .FirstOrDefaultAsync(cancellationToken);

        if (connection == null)
        {
            return null;
        }

        return await _groups
            .Find(g => g.Id == connection.GroupId)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<PagedList<Group>> GetGroupsRawAsync(GroupParams groupParams, CancellationToken cancellationToken = default)
    {
        var query = _groups.AsQueryable()
            .Where(m => m.UserIds.Contains(groupParams.UserId));

        if (groupParams.OrderBy == "updatedAt")
        {
            query = groupParams.SortBy == "asc" ? query.OrderBy(m => m.UpdatedAt) : query.OrderByDescending(m => m.UpdatedAt);
        }
        
        return await PagedList<Group>.CreateAsync(
            query,
            groupParams.PageNumber,
            groupParams.PageSize,
            cancellationToken
        );
    }

    public async Task<List<Group>> GetGroupsForUserAsync(string userId, CancellationToken cancellationToken = default)
    {
        return await _groups
            .Find(g => g.UserIds.Contains(userId) && g.HasMessage)
            .ToListAsync(cancellationToken);
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
