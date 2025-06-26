using FluentValidation;

namespace OrderService.Core.Application.Commands.ConfirmOrderPayment;

public class ConfirmOrderPaymentValidator : AbstractValidator<ConfirmOrderPaymentCommand>
{
    public ConfirmOrderPaymentValidator()
    {
        RuleFor(x => x.PaymentIntentId)
            .NotEmpty()
            .WithMessage("Payment intent ID is required.")
            .MaximumLength(100)
            .WithMessage("Payment intent ID must not exceed 100 characters.");
    }
}
