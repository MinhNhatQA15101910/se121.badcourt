using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetRatings;

public record GetRatingsQuery(RatingParams RatingParams) : IQuery<PagedList<RatingDto>>;
