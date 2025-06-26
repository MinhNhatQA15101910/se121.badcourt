using FacilityService.Core.Application.Commands;
using FluentValidation;

namespace FacilityService.Core.Application.Validators;

public class DeleteFacilityValidator : AbstractValidator<DeleteFacilityCommand>
{
    public DeleteFacilityValidator()
    {
        RuleFor(command => command.FacilityId)
            .NotEmpty().WithMessage("Facility ID must not be empty.")
            .Matches("^[a-fA-F0-9]{24}$").WithMessage("Facility ID must be a valid ObjectId format.");
    }
}
