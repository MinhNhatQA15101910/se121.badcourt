using MediatR;

namespace PostService.Application.Notifications.CommentCreated;

public record CommentCreatedNotification(string PostId, string UserId) : INotification;
