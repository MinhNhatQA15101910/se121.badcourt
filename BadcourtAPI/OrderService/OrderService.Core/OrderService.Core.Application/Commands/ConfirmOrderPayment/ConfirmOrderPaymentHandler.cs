
using OrderService.Core.Domain.Enums;
using OrderService.Core.Domain.Repositories;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Commands.ConfirmOrderPayment;

public class ConfirmOrderPaymentHandler(
    IOrderRepository orderRepository
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

        return true;
    }
}
