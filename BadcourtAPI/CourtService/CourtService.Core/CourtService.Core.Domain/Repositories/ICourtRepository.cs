using CourtService.Core.Domain.Entities;

namespace CourtService.Core.Domain.Repositories;

public interface ICourtRepository
{
    Task InsertManyAsync(IEnumerable<Court> facilities, CancellationToken cancellationToken = default);
}
