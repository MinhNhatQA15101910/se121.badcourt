
using MassTransit.Mediator;
using Microsoft.AspNetCore.Http;
using PostService.Application.Extensions;
using PostService.Application.Notifications.PostDeleted;
using PostService.Domain.Interfaces;
using SharedKernel.Exceptions;

namespace PostService.Application.Commands.DeletePost;

public class DeletePostHandler(
    IHttpContextAccessor httpContextAccessor,
    IPostRepository postRepository,
    IMediator mediator
) : ICommandHandler<DeletePostCommand, bool>
{
    public async Task<bool> Handle(DeletePostCommand request, CancellationToken cancellationToken)
    {
        var post = await postRepository.GetPostByIdAsync(request.PostId, cancellationToken)
            ?? throw new PostNotFoundExceptions(request.PostId);

        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (!roles.Contains("Admin"))
        {
            var userId = httpContextAccessor.HttpContext.User.GetUserId();
            if (post.PublisherId != userId)
            {
                throw new UnauthorizedAccessException("You are not allowed to delete this post.");
            }
        }

        await postRepository.DeletePostAsync(post, cancellationToken);

        var postDeletedNotification = new PostDeletedNotification(post.Id);
        await mediator.Publish(postDeletedNotification, cancellationToken);

        return true;
    }
}
