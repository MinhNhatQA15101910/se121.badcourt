using CourtService.Core.Application.Commands;
using CourtService.Core.Application.DTOs;
using CourtService.Core.Application.Queries;
using CourtService.Presentation.Extensions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
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

    [Authorize(Roles = "Admin, Manager")]
    [HttpPost]
    public async Task<ActionResult<CourtDto>> AddCourt(AddCourtDto addCourtDto)
    {
        var court = await mediator.Send(new AddCourtCommand(addCourtDto));
        return CreatedAtAction(nameof(GetCourt), new { id = court.Id }, court);
    }

    [Authorize(Roles = "Admin, Manager")]
    [HttpPut("{id:length(24)}")]
    public async Task<IActionResult> UpdateCourt(string id, UpdateCourtDto updateCourtDto)
    {
        await mediator.Send(new UpdateCourtCommand(id, updateCourtDto));
        return NoContent();
    }

    [Authorize(Roles = "Admin, Manager")]
    [HttpPut("update-inactive/{id:length(24)}")]
    public async Task<IActionResult> UpdateInactive(string id, UpdateInactiveDto updateInactiveDto)
    {
        await mediator.Send(new UpdateInactiveCommand(id, updateInactiveDto));
        return NoContent();
    }

    [Authorize(Roles = "Admin, Manager")]
    [HttpDelete("{id:length(24)}")]
    public async Task<IActionResult> DeleteCourt(string id)
    {
        var command = new DeleteCourtCommand(id);
        await mediator.Send(command);
        return Ok();
    }
}
