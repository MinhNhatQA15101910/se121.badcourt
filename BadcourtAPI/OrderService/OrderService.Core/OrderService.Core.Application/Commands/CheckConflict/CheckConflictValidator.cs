using FluentValidation;

namespace OrderService.Core.Application.Commands.CheckConflict;

public class CheckConflictValidator : AbstractValidator<CheckConflictCommand>
{
    public CheckConflictValidator()
    {
        RuleFor(x => x.CheckConflictDto.CourtId)
            .NotEmpty()
            .WithMessage("CourtId is required.");

        RuleFor(x => x.CheckConflictDto.DateTimePeriod)
            .NotNull()
            .WithMessage("DateTimePeriod is required.");

    }
}
