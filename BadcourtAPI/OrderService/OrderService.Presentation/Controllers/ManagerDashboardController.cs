using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Queries.GetMonthlyRevenue;
using SharedKernel.Params;

namespace OrderService.Presentation.Controllers;

[Route("api/manager-dashboard")]
[ApiController]
public class ManagerDashboardController(IMediator mediator) : ControllerBase
{
    [HttpGet("monthly-revenue")]
    [Authorize(Roles = "Admin, Manager")]
    public async Task<IActionResult> GetMonthlyRevenue(
        [FromQuery] ManagerDashboardMonthlyRevenueParams managerDashboardMonthlyRevenueParams)
    {
        var query = new GetMonthlyRevenueQuery(managerDashboardMonthlyRevenueParams);
        var result = await mediator.Send(query);

        return Ok(result);
    }
}
