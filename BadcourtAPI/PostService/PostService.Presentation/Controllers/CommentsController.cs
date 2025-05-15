using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PostService.Application.Commands.CreateComment;
using SharedKernel.DTOs;

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
}
