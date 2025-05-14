using AutoMapper;
using PostService.Domain.Interfaces;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace PostService.Application.Queries.GetPostById;

public class GetPostByIdHandler(
    IPostRepository postRepository,
    IMapper mapper
) : IQueryHandler<GetPostByIdQuery, PostDto>
{
    public async Task<PostDto> Handle(GetPostByIdQuery request, CancellationToken cancellationToken)
    {
        var post = await postRepository.GetPostByIdAsync(request.Id, cancellationToken)
            ?? throw new PostNotFoundExceptions(request.Id);

        return mapper.Map<PostDto>(post);
    }
}
