using AutoMapper;
using Microsoft.AspNetCore.Http;
using PostService.Application.Extensions;
using PostService.Domain.Interfaces;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace PostService.Application.Queries.GetPostById;

public class GetPostByIdHandler(
    IHttpContextAccessor httpContextAccessor,
    IPostRepository postRepository,
    IMapper mapper
) : IQueryHandler<GetPostByIdQuery, PostDto>
{
    public async Task<PostDto> Handle(GetPostByIdQuery request, CancellationToken cancellationToken)
    {
        var post = await postRepository.GetPostByIdAsync(request.Id, cancellationToken)
            ?? throw new PostNotFoundExceptions(request.Id);

        var postDto = mapper.Map<PostDto>(post);

        try
        {
            var userId = httpContextAccessor.HttpContext.User.GetUserId();

            if (post.LikedUsers.Contains(userId.ToString()))
            {
                postDto.IsLiked = true;
            }

            return postDto;
        }
        catch (Exception)
        {
            return postDto;
        }
    }
}
