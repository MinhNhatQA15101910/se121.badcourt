namespace AuthService.Core.Application.Commands;

public record UnlockUserCommand(Guid UserId) : ICommand<bool>;
