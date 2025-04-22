using AuthService.Core.Application.DTOs;

namespace AuthService.Core.Application.Commands;

public record ResetPasswordCommand(ResetPasswordDto ResetPasswordDto) : ICommand<bool>;
