using Application.Commands.Users;
using FluentValidation;

namespace Application.Validators.Users;

public class ChangePasswordValidator : AbstractValidator<ChangePasswordCommand>
{
    public ChangePasswordValidator()
    {
        RuleFor(x => x.ChangePasswordDto.CurrentPassword)
            .NotEmpty().WithMessage("CurrentPassword is required.");

        RuleFor(x => x.ChangePasswordDto.NewPassword)
            .NotEmpty().WithMessage("NewPassword is required.")
            .MinimumLength(6).WithMessage("NewPassword must be at least 6 characters long.")
            .NotEqual(x => x.ChangePasswordDto.CurrentPassword).WithMessage("NewPassword should not be the same as CurrentPassword.");
    }
}
