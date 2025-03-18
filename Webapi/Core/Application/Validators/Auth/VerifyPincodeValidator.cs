using Application.Commands.Auth;
using FluentValidation;

namespace Application.Validators.Auth;

public class VerifyPincodeValidator : AbstractValidator<VerifyPincodeCommand>
{
    public VerifyPincodeValidator()
    {
        RuleFor(x => x.VerifyPincodeDto.Pincode)
            .NotEmpty().WithMessage("Pincode is required")
            .MinimumLength(6).WithMessage("Pincode must be at least 6 characters long")
            .MaximumLength(6).WithMessage("Pincode must not be more than 6 characters long")
            .Matches("^[0-9]*$").WithMessage("Pincode must contain only numbers");
    }
}
