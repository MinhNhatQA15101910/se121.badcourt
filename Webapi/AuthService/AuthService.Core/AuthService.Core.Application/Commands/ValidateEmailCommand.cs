using AuthService.Core.Application.DTOs;

namespace AuthService.Core.Application.Commands;

public record ValidateEmailCommand(ValidateEmailDto ValidateEmailDto) : ICommand<object>;
