
using AutoMapper;
using MassTransit;
using OrderService.Core.Domain.Enums;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Commands.ConfirmOrderPayment;

public class ConfirmOrderPaymentHandler(
    IOrderRepository orderRepository,
    IPublishEndpoint publishEndpoint,
    IMapper mapper
) : ICommandHandler<ConfirmOrderPaymentCommand, bool>
{
    public async Task<bool> Handle(ConfirmOrderPaymentCommand request, CancellationToken cancellationToken)
    {
        var order = await orderRepository.GetByPaymentIntentIdAsync(request.PaymentIntentId, cancellationToken)
            ?? throw new OrderNotFoundException(request.PaymentIntentId);

        if (order.State != OrderState.Pending)
            return true;

        order.State = OrderState.NotPlay;
        order.UpdatedAt = DateTime.UtcNow;

        if (!await orderRepository.CompleteAsync(cancellationToken))
        {
            throw new BadRequestException("Failed to update order state.");
        }

        await publishEndpoint.Publish(new OrderCreatedEvent(
            order.Id.ToString(),
            order.CourtId,
            order.UserId.ToString(),
            mapper.Map<DateTimePeriodDto>(order.DateTimePeriod)
        ), cancellationToken);

        return true;
    }
}
