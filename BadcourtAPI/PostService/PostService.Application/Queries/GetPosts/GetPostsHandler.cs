using PostService.Domain.Interfaces;
using SharedKernel;
using SharedKernel.DTOs;

namespace PostService.Application.Queries.GetPosts;

public class GetPostsHandler(IPostRepository postRepository) : IQueryHandler<GetPostsQuery, PagedList<PostDto>>
{
    public async Task<PagedList<PostDto>> Handle(GetPostsQuery request, CancellationToken cancellationToken)
    {
        return await postRepository.GetPostsAsync(request.PostParams, cancellationToken);
    }
}
