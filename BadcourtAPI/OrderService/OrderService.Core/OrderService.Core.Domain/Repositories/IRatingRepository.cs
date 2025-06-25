using OrderService.Core.Domain.Entities;

namespace OrderService.Core.Domain.Repositories;

public interface IRatingRepository
{
    Task<Rating?> GetRatingByIdAsync(Guid ratingId, CancellationToken cancellationToken = default);
}
