using Application.DTOs.Auth;

namespace Application.Commands.Auth;

public record ValidateEmailCommand(ValidateEmailDto ValidateEmailDto) : ICommand<object>;
