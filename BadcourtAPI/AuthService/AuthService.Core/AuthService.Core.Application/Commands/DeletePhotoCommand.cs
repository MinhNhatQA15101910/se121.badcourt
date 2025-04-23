namespace AuthService.Core.Application.Commands;

public record DeletePhotoCommand(Guid UserId, Guid PhotoId) : ICommand<bool>;
