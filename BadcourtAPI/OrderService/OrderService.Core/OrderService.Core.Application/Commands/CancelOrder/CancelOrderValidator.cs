using FluentValidation;

namespace OrderService.Core.Application.Commands.CancelOrder;

public class CancelOrderValidator : AbstractValidator<CancelOrderCommand>
{
    public CancelOrderValidator()
    {
        RuleFor(x => x.OrderId)
            .NotEmpty().WithMessage("Order ID must not be empty.")
            .NotEqual(Guid.Empty).WithMessage("Order ID must not be an empty GUID.");
    }
}
