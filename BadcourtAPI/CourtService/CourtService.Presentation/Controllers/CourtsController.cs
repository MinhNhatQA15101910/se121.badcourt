using CourtService.Core.Application.Queries;
using CourtService.Presentation.Extensions;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace CourtService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class CourtsController(IMediator mediator) : ControllerBase
{
    [HttpGet("{id:length(24)}")]
    public async Task<ActionResult<CourtDto>> GetCourt(string id)
    {
        var court = await mediator.Send(new GetCourtByIdQuery(id));
        return Ok(court);
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<CourtDto>>> GetCourts([FromQuery] CourtParams courtParams)
    {
        var courts = await mediator.Send(new GetCourtsQuery(courtParams));

        Response.AddPaginationHeader(courts);

        return Ok(courts);
    }
}
