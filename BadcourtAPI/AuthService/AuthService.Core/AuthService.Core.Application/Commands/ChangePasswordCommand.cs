using AuthService.Core.Application.DTOs;

namespace AuthService.Core.Application.Commands;

public record ChangePasswordCommand(ChangePasswordDto ChangePasswordDto) : ICommand<bool>;
