using CourtService.Core.Application.Commands;
using FluentValidation;

namespace CourtService.Core.Application.Validators;

public class UpdateCourtValidator : AbstractValidator<UpdateCourtCommand>
{
    public UpdateCourtValidator()
    {
        RuleFor(x => x.UpdateCourtDto.CourtName)
            .NotEmpty()
            .WithMessage("Court name is required.")
            .MaximumLength(100)
            .WithMessage("Court name must not exceed 100 characters.");

        RuleFor(x => x.UpdateCourtDto.Description)
            .NotEmpty()
            .WithMessage("Description is required.");

        RuleFor(x => x.UpdateCourtDto.PricePerHour)
            .GreaterThan(0)
            .WithMessage("Price per hour must be greater than zero.");
    }
}
