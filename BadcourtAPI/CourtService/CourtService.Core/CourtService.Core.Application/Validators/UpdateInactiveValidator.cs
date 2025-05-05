using CourtService.Core.Application.Commands;
using FluentValidation;

namespace CourtService.Core.Application.Validators;

public class UpdateInactiveValidator : AbstractValidator<UpdateInactiveCommand>
{
    public UpdateInactiveValidator()
    {
        RuleFor(x => x.DateTimePeriodDto).NotNull().WithMessage("Time period cannot be null.");
        RuleFor(x => x.DateTimePeriodDto.HourFrom)
            .NotEmpty().WithMessage("Start hour cannot be empty.")
            .LessThan(x => x.DateTimePeriodDto.HourTo).WithMessage("Start hour must be before end hour.");
        RuleFor(x => x.DateTimePeriodDto.HourTo)
            .NotEmpty().WithMessage("End hour cannot be empty.")
            .GreaterThan(x => x.DateTimePeriodDto.HourFrom).WithMessage("End hour must be after start hour.");
    }
}
