using MediatR;

namespace PostService.Application.Notifications.PostDeleted;

public record PostDeletedNotification(string PostId) : INotification;
