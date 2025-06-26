using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetRatingById;

public record GetRatingByIdQuery(Guid RatingId) : IQuery<RatingDto>;
