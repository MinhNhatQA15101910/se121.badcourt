using OrderService.Core.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Domain.Repositories;

public interface IRatingRepository
{
    Task<Rating?> GetRatingByIdAsync(Guid ratingId, CancellationToken cancellationToken = default);
    Task<PagedList<RatingDto>> GetRatingsAsync(RatingParams ratingParams, CancellationToken cancellationToken = default);
}
