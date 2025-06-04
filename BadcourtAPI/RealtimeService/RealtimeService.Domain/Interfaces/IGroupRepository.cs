using RealtimeService.Domain.Entities;
using SharedKernel;
using SharedKernel.Params;

namespace RealtimeService.Domain.Interfaces;

public interface IGroupRepository
{
    Task AddGroupAsync(Group group, CancellationToken cancellationToken = default);
    Task<Group?> GetGroupByNameAsync(string groupName, CancellationToken cancellationToken = default);
    Task<Group?> GetGroupForConnectionAsync(string connectionId, CancellationToken cancellationToken = default);
    Task<PagedList<Group>> GetGroupsRawAsync(GroupParams groupParams, CancellationToken cancellationToken = default);
    Task UpdateGroupAsync(Group group, CancellationToken cancellationToken = default);
}
