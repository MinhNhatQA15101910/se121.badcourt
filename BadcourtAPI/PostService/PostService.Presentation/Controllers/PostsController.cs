using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PostService.Application.Commands.CreatePost;
using PostService.Application.Queries.GetPostById;
using SharedKernel.DTOs;

namespace PostService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class PostsController(IMediator mediator) : ControllerBase
{
    [HttpGet("{id}")]
    public async Task<ActionResult<PostDto>> GetPostById(string id)
    {
        var post = await mediator.Send(new GetPostByIdQuery(id));
        return post;
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<PostDto>> CreatePost(CreatePostDto createPostDto)
    {
        var post = await mediator.Send(new CreatePostCommand(createPostDto));
        return CreatedAtAction(nameof(GetPostById), new { id = post.Id }, post);
    }
}
