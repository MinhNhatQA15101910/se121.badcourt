using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PostService.Application.Commands.CreateComment;
using PostService.Application.Commands.ToggleLikeComment;
using PostService.Application.Queries.GetComments;
using PostService.Presentation.Extensions;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace PostService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class CommentsController(IMediator mediator) : ControllerBase
{
    [HttpPost]
    [Authorize]
    public async Task<ActionResult<CommentDto>> CreateComment(CreateCommentDto createCommentDto)
    {
        var comment = await mediator.Send(new CreateCommentCommand(createCommentDto));
        return comment;
    }

    [HttpGet]
    public async Task<PagedList<CommentDto>> GetComments([FromQuery] CommentParams commentParams)
    {
        var comments = await mediator.Send(new GetCommentsQuery(commentParams));

        Response.AddPaginationHeader(comments);

        return comments;
    }

    [HttpPost("toggle-like/{id}")]
    [Authorize]
    public async Task<IActionResult> ToggleLikeComment(string id)
    {
        await mediator.Send(new ToggleLikeCommentCommand(id));
        return NoContent();
    }
}
