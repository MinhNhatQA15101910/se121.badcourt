using CourtService.Core.Application.DTOs;
using FluentValidation;

namespace CourtService.Core.Application.Validators;

public class AddCourtValidator : AbstractValidator<AddCourtDto>
{
    public AddCourtValidator()
    {
        RuleFor(c => c.FacilityId)
            .NotEmpty()
            .WithMessage("Facility ID is required.");

        RuleFor(c => c.CourtName)
            .NotEmpty()
            .WithMessage("Court name is required.");

        RuleFor(c => c.Description)
            .NotEmpty()
            .WithMessage("Description is required.");

        RuleFor(c => c.PricePerHour)
            .GreaterThan(1000)
            .WithMessage("Price per hour must be greater than 1000 VNĐ.");
    }
}
