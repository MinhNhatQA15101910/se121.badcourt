
using RealtimeService.Domain.Entities;

namespace RealtimeService.Domain.Interfaces;

public interface ICourtRepository
{
    Task AddCourtAsync(Court court, CancellationToken cancellationToken = default);
    Task<bool> AnyAsync(CancellationToken cancellationToken = default);
}
