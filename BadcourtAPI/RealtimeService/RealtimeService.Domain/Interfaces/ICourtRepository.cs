
using Microsoft.Extensions.Primitives;
using RealtimeService.Domain.Entities;

namespace RealtimeService.Domain.Interfaces;

public interface ICourtRepository
{
    Task AddCourtAsync(Court court, CancellationToken cancellationToken = default);
    Task<bool> AnyAsync(CancellationToken cancellationToken = default);
    Task<Court?> GetCourtByIdAsync(string courtId, CancellationToken cancellationToken = default);
    Task UpdateCourtAsync(Court court, CancellationToken cancellationToken = default);
}
