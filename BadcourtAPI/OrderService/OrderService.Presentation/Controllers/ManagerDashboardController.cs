using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Queries.GetTotalRevenueForManager;
using SharedKernel.Params;

namespace OrderService.Presentation.Controllers;

[Route("api/manager-dashboard")]
[ApiController]
public class ManagerDashboardController(IMediator mediator) : ControllerBase
{
    [HttpGet("total-revenue")]
    [Authorize(Roles = "Manager")]
    public async Task<IActionResult> GetTotalRevenue(
        [FromQuery] ManagerDashboardSummaryParams summaryParams)
    {
        var query = new GetTotalRevenueForManagerQuery(summaryParams);
        var result = await mediator.Send(query);

        return Ok(result);
    }
}
