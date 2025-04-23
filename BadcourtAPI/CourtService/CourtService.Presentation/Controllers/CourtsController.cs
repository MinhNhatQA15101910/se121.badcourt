using CourtService.Core.Application.Queries;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using SharedKernel.DTOs;

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
}
