using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PostService.Application.Commands.CreatePost;
using PostService.Application.Commands.DeletePost;
using PostService.Application.Commands.ToggleLikePost;
using PostService.Application.Queries.GetPostById;
using PostService.Application.Queries.GetPosts;
using PostService.Presentation.Extensions;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

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

    [HttpGet]
    public async Task<ActionResult<PagedList<PostDto>>> GetPosts([FromQuery] PostParams postParams)
    {
        var posts = await mediator.Send(new GetPostsQuery(postParams));

        Response.AddPaginationHeader(posts);

        return Ok(posts);
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<PostDto>> CreatePost(CreatePostDto createPostDto)
    {
        var post = await mediator.Send(new CreatePostCommand(createPostDto));
        return CreatedAtAction(nameof(GetPostById), new { id = post.Id }, post);
    }

    [HttpPost("toggle-like/{id}")]
    [Authorize]
    public async Task<IActionResult> ToggleLike(string id)
    {
        await mediator.Send(new ToggleLikePostCommand(id));
        return NoContent();
    }

    [HttpDelete("{postId}")]
    [Authorize]
    public async Task<IActionResult> DeletePost(string postId)
    {
        var command = new DeletePostCommand(postId);
        await mediator.Send(command);
        return Ok();
    }
}
