using RealtimeService.Domain.Entities;

namespace RealtimeService.Domain.Interfaces;

public interface IGroupRepository
{
    Task AddGroupAsync(Group group, CancellationToken cancellationToken = default);
    Task<Group?> GetGroupByNameAsync(string groupName, CancellationToken cancellationToken = default);
    Task<Group?> GetGroupForConnectionAsync(string connectionId, CancellationToken cancellationToken = default);
    Task<List<Group>> GetGroupsForUserAsync(string userId, CancellationToken cancellationToken = default);
    Task UpdateGroupAsync(Group group, CancellationToken cancellationToken = default);
}
