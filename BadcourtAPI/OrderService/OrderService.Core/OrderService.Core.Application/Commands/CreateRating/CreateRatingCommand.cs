using SharedKernel.DTOs;

namespace OrderService.Core.Application.Commands.CreateRating;

public record CreateRatingCommand(Guid OrderId, CreateRatingDto CreateRatingDto) : ICommand<RatingDto>;
