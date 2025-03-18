namespace Application.Commands.Users;

public record DeletePhotoCommand(Guid UserId, Guid PhotoId) : ICommand<bool>;
