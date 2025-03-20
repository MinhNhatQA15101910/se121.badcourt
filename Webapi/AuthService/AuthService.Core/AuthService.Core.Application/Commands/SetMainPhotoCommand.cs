namespace AuthService.Core.Application.Commands;

public record SetMainPhotoCommand(Guid UserId, Guid PhotoId) : ICommand<bool>;
