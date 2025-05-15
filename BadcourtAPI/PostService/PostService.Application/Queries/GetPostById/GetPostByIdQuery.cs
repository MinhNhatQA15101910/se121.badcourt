using SharedKernel.DTOs;

namespace PostService.Application.Queries.GetPostById;

public record GetPostByIdQuery(string Id) : IQuery<PostDto>;
