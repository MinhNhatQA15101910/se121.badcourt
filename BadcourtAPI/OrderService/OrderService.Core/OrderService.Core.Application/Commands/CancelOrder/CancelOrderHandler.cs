
using AutoMapper;
using MassTransit;
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Application.Interfaces;
using OrderService.Core.Domain.Enums;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Commands.CancelOrder;

public class CancelOrderHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository,
    IStripeService stripeService,
    IPublishEndpoint publishEndpoint,
    IMapper mapper
) : ICommandHandler<CancelOrderCommand, bool>
{
    public async Task<bool> Handle(CancelOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await orderRepository.GetOrderByIdAsync(request.OrderId, cancellationToken)
            ?? throw new OrderNotFoundException(request.OrderId);

        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (!roles.Contains("Admin"))
        {
            var userId = httpContextAccessor.HttpContext.User.GetUserId();
            if (order.UserId != userId)
            {
                throw new UnauthorizedAccessException("You do not have permission to cancel this order.");
            }
        }

        if (order.State != OrderState.NotPlay)
        {
            throw new BadRequestException("Order cannot be cancelled as it is not in a cancellable state.");
        }

        // If the current time is within 1 day of the order's hourFrom, don't allow cancellation
        if (order.DateTimePeriod.HourFrom < DateTime.UtcNow.AddDays(1))
        {
            throw new BadRequestException("Order cannot be cancelled within 24 hours of the scheduled time.");
        }

        // Calculate the refund amount
        var refundAmount = order.Price * 0.8m; // 80% refund

        // Call Stripe refund
        await stripeService.CreateRefundAsync(order.PaymentIntentId, refundAmount, cancellationToken);

        order.State = OrderState.Cancelled;
        order.Price -= refundAmount; // Adjust the price to reflect the refund
        order.UpdatedAt = DateTime.UtcNow;

        if (!await orderRepository.CompleteAsync(cancellationToken))
        {
            throw new BadRequestException("Failed to update the order status to cancelled.");
        }

        await publishEndpoint.Publish(new OrderCancelledEvent(
            order.Id.ToString(),
            order.CourtId,
            httpContextAccessor.HttpContext.User.GetUserId().ToString(),
            mapper.Map<DateTimePeriodDto>(order.DateTimePeriod)
        ), cancellationToken);

        return true;
    }
}
