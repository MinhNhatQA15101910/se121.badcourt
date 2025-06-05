using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RealtimeService.Application.Queries.GetMessages;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class MessagesController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<PagedResult<MessageDto>>> GetMessages([FromQuery] MessageParams messageParams)
    {
        return await mediator.Send(new GetMessagesQuery(messageParams));
    }
}
