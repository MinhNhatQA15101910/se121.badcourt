using MediatR;

namespace PostService.Application.Notifications;

public record CommentCreatedNotification(string PostId, string UserId) : INotification;
