using RealtimeService.Domain.Entities;

namespace RealtimeService.Domain.Interfaces;

public interface IConnectionRepository
{
    Task DeleteConnectionAsync(string connectionId, CancellationToken cancellationToken = default);
    Task<Connection?> GetConnectionByIdAsync(string connectionId, CancellationToken cancellationToken = default);
}
