namespace Application.Commands.Users;

public record SetMainPhotoCommand(Guid UserId, Guid PhotoId) : ICommand<bool>;
