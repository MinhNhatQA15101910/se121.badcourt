using CourtService.Core.Application.Commands;
using FluentValidation;

namespace CourtService.Core.Application.Validators;

public class UpdateInactiveValidator : AbstractValidator<UpdateInactiveCommand>
{
    public UpdateInactiveValidator()
    {
        RuleFor(command => command.CourtId)
            .NotEmpty()
            .WithMessage("Court ID cannot be empty.");

        RuleFor(command => command.UpdateInactiveDto.DateTimePeriod.HourFrom)
            .NotEmpty()
            .WithMessage("HourFrom cannot be empty.");

        RuleFor(command => command.UpdateInactiveDto.DateTimePeriod.HourTo)
            .NotEmpty()
            .WithMessage("HourTo cannot be empty.");
    }
}
