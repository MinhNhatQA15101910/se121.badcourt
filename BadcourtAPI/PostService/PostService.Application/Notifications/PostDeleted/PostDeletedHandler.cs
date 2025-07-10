using MediatR;
using PostService.Domain.Interfaces;

namespace PostService.Application.Notifications.PostDeleted;

public class PostDeletedHandler(
    ICommentRepository commentRepository
) : INotificationHandler<PostDeletedNotification>
{
    public async Task Handle(PostDeletedNotification notification, CancellationToken cancellationToken)
    {
        await commentRepository.DeleteCommentsByPostIdAsync(notification.PostId, cancellationToken);
    }
}
