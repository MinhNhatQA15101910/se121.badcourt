using AutoMapper;
using AutoMapper.QueryableExtensions;
using OrderService.Core.Domain.Entities;
using OrderService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Infrastructure.Persistence.Repositories;

public class RatingRepository(
    DataContext context,
    IMapper mapper
) : IRatingRepository
{
    public async Task<Rating?> GetRatingByIdAsync(Guid ratingId, CancellationToken cancellationToken = default)
    {
        return await context.Ratings
            .FindAsync([ratingId, cancellationToken], cancellationToken: cancellationToken);
    }

    public async Task<PagedList<RatingDto>> GetRatingsAsync(RatingParams ratingParams, CancellationToken cancellationToken = default)
    {
        var query = context.Ratings.AsQueryable();

        // Filter by userId
        if (ratingParams.UserId != null)
        {
            query = query.Where(o => o.UserId == ratingParams.UserId);
        }

        // Filter by facilityId
        if (ratingParams.FacilityId != null)
        {
            query = query.Where(o => o.FacilityId == ratingParams.FacilityId);
        }

        // Filter by stars range
        query = query.Where(o =>
            o.Stars >= ratingParams.MinStars &&
            o.Stars <= ratingParams.MaxStars
        );

        // Order
        query = ratingParams.OrderBy switch
        {
            "createdAt" => ratingParams.SortBy == "asc"
                ? query.OrderBy(o => o.CreatedAt)
                : query.OrderByDescending(o => o.CreatedAt),
            "stars" => ratingParams.SortBy == "asc"
                ? query.OrderBy(o => o.Stars)
                : query.OrderByDescending(o => o.Stars),
            _ => query.OrderBy(o => o.CreatedAt)
        };

        return await PagedList<RatingDto>.CreateAsync(
            query.ProjectTo<RatingDto>(mapper.ConfigurationProvider),
            ratingParams.PageNumber,
            ratingParams.PageSize
        );
    }
}
