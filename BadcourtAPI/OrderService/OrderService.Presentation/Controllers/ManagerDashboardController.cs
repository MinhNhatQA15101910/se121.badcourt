using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Queries.GetFacilityRevenue;
using OrderService.Core.Application.Queries.GetMonthlyRevenue;
using OrderService.Core.Application.Queries.GetOrderDetails;
using OrderService.Presentation.Extensions;
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

    [HttpGet("facility-revenue")]
    [Authorize(Roles = "Admin, Manager")]
    public async Task<IActionResult> GetFacilityRevenue(
        [FromQuery] ManagerDashboardFacilityRevenueParams managerDashboardFacilityRevenueParams)
    {
        var query = new GetFacilityRevenueQuery(managerDashboardFacilityRevenueParams);
        var result = await mediator.Send(query);

        return Ok(result);
    }

    [HttpGet("orders")]
    [Authorize(Roles = "Admin, Manager")]
    public async Task<IActionResult> GetOrderDetails(
        [FromQuery] OrderParams orderParams)
    {
        var query = new GetOrderDetailsQuery(orderParams);
        var result = await mediator.Send(query);

        Response.AddPaginationHeader(result);

        return Ok(result);
    }
}
