using Stripe;

namespace OrderService.Core.Application.Interfaces;

public interface IStripeService
{
    Task<PaymentIntent> CreatePaymentIntentAsync(decimal amount, string currency = "vnd",
        CancellationToken cancellationToken = default);
    Task<Refund> CreateRefundAsync(string paymentIntentId, decimal amountVND,
        CancellationToken cancellationToken = default);
}
