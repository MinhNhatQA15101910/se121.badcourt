
using MassTransit;
using Microsoft.AspNetCore.Http;
using PostService.Application.Extensions;
using PostService.Domain.Interfaces;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace PostService.Application.Commands.ToggleLikeComment;

public class ToggleLikeCommentHandler(
    IHttpContextAccessor httpContextAccessor,
    ICommentRepository commentRepository,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<ToggleLikeCommentCommand, bool>
{
    public async Task<bool> Handle(ToggleLikeCommentCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        var comment = await commentRepository.GetCommentByIdAsync(request.CommentId, cancellationToken)
            ?? throw new CommentNotFoundException(request.CommentId);

        if (comment.LikedUsers.Contains(userId.ToString()))
        {
            comment.LikedUsers = [.. comment.LikedUsers.Where(x => x != userId.ToString())];
            comment.LikesCount--;
        }
        else
        {
            comment.LikedUsers = [.. comment.LikedUsers, userId.ToString()];
            comment.LikesCount++;

            if (userId.ToString() != comment.PublisherId.ToString())
            {
                await publishEndpoint.Publish(
                    new CommentLikedEvent(comment.Id, comment.PublisherId.ToString(), httpContextAccessor.HttpContext.User.GetUsername()),
                    cancellationToken
                );
            }
        }

        comment.UpdatedAt = DateTime.UtcNow;
        await commentRepository.UpdateCommentAsync(comment, cancellationToken);

        return true;
    }
}
