using Application.DTOs.Users;

namespace Application.Commands.Users;

public record ChangePasswordCommand(ChangePasswordDto ChangePasswordDto) : ICommand<bool>;
