using MassTransit;
using PostService.Domain.Enums;
using PostService.Domain.Interfaces;
using SharedKernel.Events;
using SharedKernel.Params;

namespace PostService.Application.Consumers;

public class UserLockedConsumer(
    IPostRepository postRepository,
    ICommentRepository commentRepository
) : IConsumer<UserLockedEvent>
{
    public async Task Consume(ConsumeContext<UserLockedEvent> context)
    {
        var userId = context.Message.UserId;

        // Update user's posts to Locked state
        await UpdatePostsToLockedAsync(userId);

        // Update user's comments to Locked state
        await UpdateCommentsToLockedAsync(userId);
    }

    private async Task UpdateCommentsToLockedAsync(string userId)
    {
        var commentParams = new CommentParams
        {
            PublisherId = userId
        };

        var comments = await commentRepository.GetAllCommentsAsync(commentParams);
        foreach (var comment in comments)
        {
            if (comment.PublisherState != UserState.Locked)
            {
                comment.PublisherState = UserState.Locked;
                await commentRepository.UpdateCommentAsync(comment);
            }
        }
    }

    private async Task UpdatePostsToLockedAsync(string userId)
    {
        var postParams = new PostParams
        {
            PublisherId = userId
        };

        var posts = await postRepository.GetAllPostsAsync(postParams);
        foreach (var post in posts)
        {
            if (post.PublisherState != UserState.Locked)
            {
                post.PublisherState = UserState.Locked;
                await postRepository.UpdatePostAsync(post);
            }
        }
    }
}
