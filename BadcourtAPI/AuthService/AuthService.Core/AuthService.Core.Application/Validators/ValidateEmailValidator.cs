using AuthService.Core.Application.Commands;
using FluentValidation;

namespace AuthService.Core.Application.Validators;

public class ValidateEmailValidator : AbstractValidator<ValidateEmailCommand>
{
    public ValidateEmailValidator()
    {
        RuleFor(x => x.ValidateEmailDto.Email)
            .NotEmpty().WithMessage("Email is required")
            .EmailAddress().WithMessage("Email is not valid");
    }
}
