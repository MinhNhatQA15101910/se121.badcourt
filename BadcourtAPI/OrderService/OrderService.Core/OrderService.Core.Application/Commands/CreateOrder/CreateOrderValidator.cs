using FluentValidation;

namespace OrderService.Core.Application.Commands.CreateOrder;

public class CreateOrderValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderValidator()
    {
        RuleFor(x => x.CreateOrderDto.CourtId)
            .NotEmpty()
            .WithMessage("CourtId is required.");

        RuleFor(x => x.CreateOrderDto.DateTimePeriod)
            .NotNull()
            .WithMessage("DateTimePeriod is required.");
        
    }
}
