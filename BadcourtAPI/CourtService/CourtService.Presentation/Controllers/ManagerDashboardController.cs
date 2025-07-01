using CourtService.Core.Application.Queries;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SharedKernel.Params;

namespace CourtService.Presentation.Controllers;

[Route("api/manager-dashboard")]
[ApiController]
public class ManagerDashboardController(IMediator mediator) : ControllerBase
{
    [HttpGet("total-courts")]
    [Authorize(Roles = "Admin,Manager")]
    public async Task<ActionResult<int>> GetTotalCourts([FromQuery] ManagerDashboardSummaryParams queryParams)
    {
        var query = new GetTotalCourtsQuery(queryParams);
        var totalCourts = await mediator.Send(query);
        return Ok(totalCourts);
    }
}
