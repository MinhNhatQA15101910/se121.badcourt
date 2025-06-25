using OrderService.Core.Domain.Entities;
using OrderService.Core.Domain.Repositories;

namespace OrderService.Infrastructure.Persistence.Repositories;

public class RatingRepository(DataContext dbContext) : IRatingRepository
{
    public async Task<Rating?> GetRatingByIdAsync(Guid ratingId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Ratings
            .FindAsync([ratingId, cancellationToken], cancellationToken: cancellationToken);
    }
}
