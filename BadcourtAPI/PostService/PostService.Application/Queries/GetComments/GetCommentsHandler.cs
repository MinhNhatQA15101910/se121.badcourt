using Microsoft.AspNetCore.Http;
using PostService.Application.Extensions;
using PostService.Domain.Interfaces;
using SharedKernel;
using SharedKernel.DTOs;

namespace PostService.Application.Queries.GetComments;

public class GetCommentsHandler(
    IHttpContextAccessor httpContextAccessor,
    ICommentRepository commentRepository
) : IQueryHandler<GetCommentsQuery, PagedList<CommentDto>>
{
    public async Task<PagedList<CommentDto>> Handle(GetCommentsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            var userId = httpContextAccessor.HttpContext.User.GetUserId();

            return await commentRepository.GetCommentsAsync(
                request.CommentParams,
                userId.ToString(),
                cancellationToken
            );
        }
        catch
        {
            return await commentRepository.GetCommentsAsync(
                request.CommentParams,
                null,
                cancellationToken
            );
        }
    }
}
