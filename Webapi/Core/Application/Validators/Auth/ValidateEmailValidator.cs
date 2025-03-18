using Application.Commands.Auth;
using FluentValidation;

namespace Application.Validators.Auth;

public class ValidateEmailValidator : AbstractValidator<ValidateEmailCommand>
{
    public ValidateEmailValidator()
    {
        RuleFor(x => x.ValidateEmailDto.Email)
            .NotEmpty().WithMessage("Email is required")
            .EmailAddress().WithMessage("Email is not valid");
    }
}
