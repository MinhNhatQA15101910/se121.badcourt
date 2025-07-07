using OrderService.Core.Application.Interfaces;
using Stripe;

namespace OrderService.Infrastructure.ExternalServices.Services;

public class StripeService : IStripeService
{
    public async Task<PaymentIntent> CreatePaymentIntentAsync(decimal amount, string currency = "vnd", 
        CancellationToken cancellationToken = default)
    {
        var options = new PaymentIntentCreateOptions
        {
            Amount = (long)amount, // VND is already in the smallest unit
            Currency = currency,
            PaymentMethodTypes = ["card"],
        };

        var service = new PaymentIntentService();
        var paymentIntent = await service.CreateAsync(options, cancellationToken: cancellationToken);
        return paymentIntent;
    }

    public Task<Refund> CreateRefundAsync(string paymentIntentId, decimal amountVND, CancellationToken cancellationToken = default)
    {
        var options = new RefundCreateOptions
        {
            PaymentIntent = paymentIntentId,
            Amount = (long)amountVND, // VND is already in the smallest unit
        };

        var service = new RefundService();
        return service.CreateAsync(options, cancellationToken: cancellationToken);
    }
}
