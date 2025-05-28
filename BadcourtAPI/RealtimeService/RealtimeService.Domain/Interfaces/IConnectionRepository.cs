using RealtimeService.Domain.Entities;

namespace RealtimeService.Domain.Interfaces;

public interface IConnectionRepository
{
    Task AddConnectionAsync(Connection connection, CancellationToken cancellationToken = default);
    Task DeleteAllAsync(CancellationToken cancellationToken = default);
    Task DeleteConnectionAsync(string connectionId, CancellationToken cancellationToken = default);
    Task<Connection?> GetConnectionByIdAsync(string connectionId, CancellationToken cancellationToken = default);
    Task<List<Connection>> GetConnectionsByGroupIdAsync(string id, CancellationToken cancellationToken = default);
}
