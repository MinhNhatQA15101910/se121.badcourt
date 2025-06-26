using ManagerService.Application.Queries.GetDashboardSummary;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ManagerService.Presentation.Controllers;

[Route("api/manager-dashboard")]
public class ManagerDashboardController(IMediator mediator) : ControllerBase
{
    [Authorize(Roles = "Admin, Manager")]
    [HttpGet("summary")]
    public async Task<ActionResult<DashboardSummaryResponse>> GetDashboardSummary()
    {
        return await mediator.Send(new GetDashboardSummaryQuery());
    }
}
