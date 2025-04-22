using FacilityService.Core.Application.Commands;
using FluentValidation;

namespace FacilityService.Core.Application.Validators;

public class UpdateActiveValidator : AbstractValidator<UpdateActiveCommand>
{
    public UpdateActiveValidator()
    {
        RuleFor(x => x.FacilityId)
            .NotEmpty()
            .WithMessage("Facility ID cannot be empty.");
    }
}
