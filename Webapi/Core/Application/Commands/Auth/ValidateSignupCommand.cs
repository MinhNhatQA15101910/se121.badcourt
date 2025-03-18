using Application.DTOs.Auth;

namespace Application.Commands.Auth;

public record ValidateSignupCommand(
    ValidateSignupDto ValidateSignupDto
) : ICommand<string>;
