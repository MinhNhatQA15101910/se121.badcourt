using CourtService.Core.Domain.Entities;

namespace CourtService.Core.Domain.Repositories;

public interface ICourtRepository
{
    Task AddCourtAsync(Court court, CancellationToken cancellationToken = default);
    Task<bool> AnyAsync(CancellationToken cancellationToken = default);
}
