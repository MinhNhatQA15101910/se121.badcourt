using AutoMapper;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Queries.GetRatingById;

public class GetRatingByIdHandler(
    IRatingRepository ratingRepository,
    IMapper mapper
) : IQueryHandler<GetRatingByIdQuery, RatingDto>
{
    public async Task<RatingDto> Handle(GetRatingByIdQuery request, CancellationToken cancellationToken)
    {
        var rating = await ratingRepository.GetRatingByIdAsync(request.RatingId, cancellationToken)
            ?? throw new RatingNotFoundException(request.RatingId);

        return mapper.Map<RatingDto>(rating);
    }
}
