using Application.DTOs.Auth;

namespace Application.Commands.Auth;

public record ResetPasswordCommand(ResetPasswordDto ResetPasswordDto) : ICommand<bool>;
