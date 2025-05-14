using Microsoft.AspNetCore.Http;
using PostService.Application.Extensions;
using PostService.Domain.Interfaces;
using SharedKernel;
using SharedKernel.DTOs;

namespace PostService.Application.Queries.GetPosts;

public class GetPostsHandler(
    IHttpContextAccessor httpContextAccessor,
    IPostRepository postRepository
) : IQueryHandler<GetPostsQuery, PagedList<PostDto>>
{
    public async Task<PagedList<PostDto>> Handle(GetPostsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            var userId = httpContextAccessor.HttpContext.User.GetUserId();
            return await postRepository.GetPostsAsync(request.PostParams, userId.ToString(), cancellationToken);
        }
        catch (Exception)
        {
            return await postRepository.GetPostsAsync(request.PostParams, null, cancellationToken: cancellationToken);
        }
    }
}
