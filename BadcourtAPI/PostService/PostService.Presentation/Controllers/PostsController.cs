using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PostService.Application.Commands.CreatePost;
using SharedKernel.DTOs;

namespace PostService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class PostsController(IMediator mediator) : ControllerBase
{
    [HttpPost]
    [Authorize]
    public async Task<ActionResult<PostDto>> CreatePost(CreatePostDto createPostDto)
    {
        var post = await mediator.Send(new CreatePostCommand(createPostDto));
        return post;
    }
}
