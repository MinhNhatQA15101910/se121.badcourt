using OrderService.Core.Application.Interfaces;
using Stripe;

namespace OrderService.Core.Application.Commands.CreateIntent;

public class CreateIntentHandler(IStripeService stripeService) : ICommandHandler<CreateIntentCommand, PaymentIntent>
{
    public async Task<PaymentIntent> Handle(CreateIntentCommand request, CancellationToken cancellationToken)
    {
        return await stripeService.CreatePaymentIntentAsync(request.CreateIntentDto.Amount, cancellationToken: cancellationToken);
    }
}
