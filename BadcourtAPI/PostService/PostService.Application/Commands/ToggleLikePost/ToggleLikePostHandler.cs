
using MassTransit;
using Microsoft.AspNetCore.Http;
using PostService.Application.Extensions;
using PostService.Domain.Interfaces;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace PostService.Application.Commands.ToggleLikePost;

public class ToggleLikePostHandler(
    IHttpContextAccessor httpContextAccessor,
    IPostRepository postRepository,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<ToggleLikePostCommand, bool>
{
    public async Task<bool> Handle(ToggleLikePostCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        var post = await postRepository.GetPostByIdAsync(request.PostId, cancellationToken)
            ?? throw new PostNotFoundExceptions(request.PostId);

        if (post.LikedUsers.Contains(userId.ToString()))
        {
            post.LikedUsers = [.. post.LikedUsers.Where(l => l != userId.ToString())];
            post.LikesCount--;
        }
        else
        {
            post.LikedUsers = [.. post.LikedUsers, userId.ToString()];
            post.LikesCount++;

            if (userId.ToString() != post.PublisherId.ToString())
            {
                await publishEndpoint.Publish(
                    new PostLikedEvent(post.Id, post.PublisherId.ToString(), httpContextAccessor.HttpContext.User.GetUsername()),
                    cancellationToken
                );
            }
        }

        post.UpdatedAt = DateTime.UtcNow;
        await postRepository.UpdatePostAsync(post, cancellationToken);

        return true;
    }
}
