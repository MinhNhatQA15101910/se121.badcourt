namespace AuthService.Core.Application.Commands;

public record LockUserCommand(Guid UserId) : ICommand<bool>;
