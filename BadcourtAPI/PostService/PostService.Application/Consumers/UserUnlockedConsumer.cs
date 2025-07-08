using MassTransit;
using PostService.Domain.Enums;
using PostService.Domain.Interfaces;
using SharedKernel.Events;
using SharedKernel.Params;

namespace PostService.Application.Consumers;

public class UserUnlockedConsumer(
    IPostRepository postRepository,
    ICommentRepository commentRepository
) : IConsumer<UserUnlockedEvent>
{
    public async Task Consume(ConsumeContext<UserUnlockedEvent> context)
    {
        var userId = context.Message.UserId;

        // Update user's posts to Locked state
        await UpdatePostsToActiveAsync(userId);

        // Update user's comments to Locked state
        await UpdateCommentsToActiveAsync(userId);
    }

    private async Task UpdateCommentsToActiveAsync(string userId)
    {
        var commentParams = new CommentParams
        {
            PublisherId = userId
        };

        var comments = await commentRepository.GetAllCommentsAsync(commentParams);
        foreach (var comment in comments)
        {
            if (comment.PublisherState != UserState.Active)
            {
                comment.PublisherState = UserState.Active;
                await commentRepository.UpdateCommentAsync(comment);
            }
        }
    }

    private async Task UpdatePostsToActiveAsync(string userId)
    {
        var postParams = new PostParams
        {
            PublisherId = userId
        };

        var posts = await postRepository.GetAllPostsAsync(postParams);
        foreach (var post in posts)
        {
            if (post.PublisherState != UserState.Active)
            {
                post.PublisherState = UserState.Active;
                await postRepository.UpdatePostAsync(post);
            }
        }
    }
}
