namespace OrderService.Core.Application.Commands.ConfirmOrderPayment;

public record ConfirmOrderPaymentCommand(string PaymentIntentId) : ICommand<bool>;
