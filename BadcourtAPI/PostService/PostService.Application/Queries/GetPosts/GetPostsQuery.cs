using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace PostService.Application.Queries.GetPosts;

public record GetPostsQuery(PostParams PostParams) : IQuery<PagedList<PostDto>>;
