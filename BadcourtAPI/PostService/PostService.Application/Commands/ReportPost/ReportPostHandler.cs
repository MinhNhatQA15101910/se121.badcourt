
using Microsoft.AspNetCore.Http;
using PostService.Application.Extensions;
using PostService.Domain.Interfaces;
using SharedKernel.Exceptions;

namespace PostService.Application.Commands.ReportPost;

public class ReportPostHandler(
    IHttpContextAccessor httpContextAccessor,
    IPostRepository postRepository
) : ICommandHandler<ReportPostCommand, bool>
{
    public async Task<bool> Handle(ReportPostCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId().ToString();

        var post = await postRepository.GetPostByIdAsync(request.PostId, cancellationToken)
            ?? throw new PostNotFoundExceptions(request.PostId);

        if (post.ReportUsers.Contains(userId))
        {
            throw new BadRequestException("You have reported this post once.");
        }

        post.ReportUsers.Add(userId);
        post.ReportsCount++;

        await postRepository.UpdatePostAsync(post, cancellationToken);

        return true;
    }
}
