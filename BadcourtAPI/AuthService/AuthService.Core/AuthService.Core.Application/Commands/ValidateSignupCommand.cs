using AuthService.Core.Application.DTOs;

namespace AuthService.Core.Application.Commands;

public record ValidateSignupCommand(
    ValidateSignupDto ValidateSignupDto
) : ICommand<string>;
