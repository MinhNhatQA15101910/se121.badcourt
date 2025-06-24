using FacilityService.Core.Application.Commands;
using FacilityService.Core.Application.DTOs;
using FacilityService.Core.Application.Queries;
using FacilityService.Presentation.Extensions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace FacilityService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class FacilitiesController(IMediator mediator) : ControllerBase
{
    [HttpGet("{id:length(24)}")]
    public async Task<ActionResult<FacilityDto>> GetFacility(string id)
    {
        var facility = await mediator.Send(new GetFacilityByIdQuery(id));
        return Ok(facility);
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserDto>>> GetFacilities([FromQuery] FacilityParams facilityParams)
    {
        var facilities = await mediator.Send(new GetFacilitiesQuery(facilityParams));

        Response.AddPaginationHeader(facilities);

        return Ok(facilities);
    }

    [HttpGet("provinces")]
    public async Task<ActionResult<IEnumerable<string>>> GetFacilityProvinces()
    {
        var provinces = await mediator.Send(new GetFacilityProvincesQuery());
        return Ok(provinces);
    }

    [Authorize(Roles = "Admin, Manager")]
    [HttpPost]
    public async Task<ActionResult<FacilityDto>> RegisterFacility([FromForm] RegisterFacilityDto registerFacilityDto)
    {
        var facility = await mediator.Send(new RegisterFacilityCommand(registerFacilityDto));
        return CreatedAtAction(
            nameof(GetFacility),
            new { id = facility.Id },
            facility
        );
    }

    [Authorize(Roles = "Admin, Manager")]
    [HttpPut("{id:length(24)}")]
    public async Task<IActionResult> UpdateFacility(string id, [FromForm] UpdateFacilityDto updateFacilityDto)
    {
        await mediator.Send(new UpdateFacilityCommand(id, updateFacilityDto));
        return NoContent();
    }

    [Authorize(Roles = "Admin, Manager")]
    [HttpPut("update-active/{id:length(24)}")]
    public async Task<IActionResult> UpdateActive(string id, ActiveDto activeDto)
    {
        await mediator.Send(new UpdateActiveCommand(id, User.GetUserId(), activeDto));
        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpPatch("approve/{id:length(24)}")]
    public async Task<IActionResult> ApproveFacility(string id)
    {
        await mediator.Send(new ApproveFacilityCommand(id));
        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpPatch("reject/{id:length(24)}")]
    public async Task<IActionResult> RejectFacility(string id)
    {
        await mediator.Send(new RejectFacilityCommand(id));
        return NoContent();
    }

    [Authorize(Roles = "Admin, Manager")]
    [HttpDelete("{id:length(24)}")]
    public async Task<IActionResult> DeleteFacility(string id)
    {
        await mediator.Send(new DeleteFacilityCommand(id));
        return Ok();
    }
}
