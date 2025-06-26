using AutoMapper;
using MassTransit;
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.ApiRepository;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Entities;
using OrderService.Core.Domain.Enums;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Commands.CreateRating;

public class CreateRatingHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository,
    IPublishEndpoint publishEndpoint,
    IFacilityApiRepository facilityApiRepository,
    IMapper mapper
) : ICommandHandler<CreateRatingCommand, RatingDto>
{
    public async Task<RatingDto> Handle(CreateRatingCommand request, CancellationToken cancellationToken)
    {
        var order = await orderRepository.GetOrderByIdAsync(request.OrderId, cancellationToken)
            ?? throw new OrderNotFoundException(request.OrderId);

        var currentUserId = httpContextAccessor.HttpContext.User.GetUserId();
        if (order.UserId != currentUserId)
        {
            throw new ForbiddenAccessException("You are not allowed to create a rating for this order.");
        }

        if (order.State != OrderState.Played)
        {
            throw new BadRequestException("You can only rate an order that has been played.");
        }

        if (order.Rating != null)
        {
            throw new BadRequestException("You have already rated this order.");
        }

        order.Rating = new Rating
        {
            UserId = currentUserId,
            FacilityId = order.FacilityId,
            Stars = request.CreateRatingDto.Stars,
            Feedback = request.CreateRatingDto.Feedback
        };
        order.UpdatedAt = DateTime.UtcNow;

        if (!await orderRepository.CompleteAsync(cancellationToken))
        {
            throw new BadRequestException("Failed to create rating.");
        }

        var facility = await facilityApiRepository.GetFacilityByIdAsync(order.FacilityId)
            ?? throw new FacilityNotFoundException(order.FacilityId);
        await publishEndpoint.Publish(new FacilityRatedEvent(
            facility.UserId.ToString(),
            order.FacilityId,
            request.CreateRatingDto.Stars
        ), cancellationToken);

        return mapper.Map<RatingDto>(order.Rating);
    }
}
