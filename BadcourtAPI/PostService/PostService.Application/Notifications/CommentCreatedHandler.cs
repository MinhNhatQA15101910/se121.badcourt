using MediatR;
using PostService.Domain.Interfaces;
using SharedKernel.Exceptions;

namespace PostService.Application.Notifications;

public class CommentCreatedHandler(IPostRepository postRepository) : INotificationHandler<CommentCreatedNotification>
{
    public async Task Handle(CommentCreatedNotification notification, CancellationToken cancellationToken)
    {
        var post = await postRepository.GetPostByIdAsync(notification.PostId, cancellationToken)
            ?? throw new PostNotFoundExceptions(notification.PostId);

        post.CommentsCount++;
        post.CommentedUsers = [.. post.CommentedUsers, notification.UserId];
        post.UpdatedAt = DateTime.UtcNow;

        await postRepository.UpdatePostAsync(post, cancellationToken);
    }
}
