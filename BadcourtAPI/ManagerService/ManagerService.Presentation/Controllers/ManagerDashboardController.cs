using ManagerService.Application.Queries.GetDashboardSummary;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SharedKernel.Params;

namespace ManagerService.Presentation.Controllers;

[Route("api/manager-dashboard")]
public class ManagerDashboardController(IMediator mediator) : ControllerBase
{
    [Authorize(Roles = "Admin, Manager")]
    [HttpGet("summary")]
    public async Task<ActionResult<DashboardSummaryResponse>> GetDashboardSummary(
        [FromQuery] ManagerDashboardSummaryParams summaryParams)
    {
        return await mediator.Send(new GetDashboardSummaryQuery(summaryParams));
    }
}
