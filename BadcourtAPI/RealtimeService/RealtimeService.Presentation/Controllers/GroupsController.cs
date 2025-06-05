using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RealtimeService.Application.Queries.GetGroups;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class GroupsController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<PagedResult<GroupDto>>> GetGroups([FromQuery] GroupParams groupParams)
    {
        return await mediator.Send(new GetGroupsQuery(groupParams));
    }
}
