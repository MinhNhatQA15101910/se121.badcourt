
using Microsoft.AspNetCore.Http;
using PostService.Application.Extensions;
using PostService.Domain.Interfaces;
using SharedKernel.Exceptions;

namespace PostService.Application.Commands.ToggleLike;

public class ToggleLikeHandler(
    IHttpContextAccessor httpContextAccessor,
    IPostRepository postRepository
) : ICommandHandler<ToggleLikeCommand, bool>
{
    public async Task<bool> Handle(ToggleLikeCommand request, CancellationToken cancellationToken)
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
        }

        await postRepository.UpdatePostAsync(post, cancellationToken);

        return true;
    }
}
