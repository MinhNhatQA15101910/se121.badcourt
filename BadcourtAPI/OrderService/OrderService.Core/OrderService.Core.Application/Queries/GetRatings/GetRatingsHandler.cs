using OrderService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetRatings;

public class GetRatingsHandler(IRatingRepository ratingRepository) : IQueryHandler<GetRatingsQuery, PagedList<RatingDto>>
{
    public async Task<PagedList<RatingDto>> Handle(GetRatingsQuery request, CancellationToken cancellationToken)
    {
        return await ratingRepository.GetRatingsAsync(
            request.RatingParams,
            cancellationToken
        );
    }
}
