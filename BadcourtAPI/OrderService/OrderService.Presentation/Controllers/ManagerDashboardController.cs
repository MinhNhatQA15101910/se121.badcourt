using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Queries.GetCourtRevenueForManager;
using OrderService.Core.Application.Queries.GetMonthlyRevenueForManager;
using OrderService.Core.Application.Queries.GetOrdersForManager;
using OrderService.Core.Application.Queries.GetTotalCustomersForManager;
using OrderService.Core.Application.Queries.GetTotalOrdersForManager;
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

    [HttpGet("total-orders")]
    [Authorize(Roles = "Manager")]
    public async Task<IActionResult> GetTotalOrders(
        [FromQuery] ManagerDashboardSummaryParams summaryParams)
    {
        var query = new GetTotalOrdersForManagerQuery(summaryParams);
        var result = await mediator.Send(query);

        return Ok(result);
    }

    [HttpGet("total-customers")]
    [Authorize(Roles = "Manager")]
    public async Task<IActionResult> GetTotalCustomers(
        [FromQuery] ManagerDashboardSummaryParams summaryParams)
    {
        var query = new GetTotalCustomersForManagerQuery(summaryParams);
        var result = await mediator.Send(query);

        return Ok(result);
    }

    [HttpGet("monthly-revenue")]
    [Authorize(Roles = "Manager")]
    public async Task<IActionResult> GetMonthlyRevenue(
        [FromQuery] ManagerDashboardMonthlyRevenueParams monthlyRevenueParams)
    {
        var query = new GetMonthlyRevenueForManagerQuery(monthlyRevenueParams);
        var result = await mediator.Send(query);

        return Ok(result);
    }

    [HttpGet("court-revenue")]
    [Authorize(Roles = "Manager")]
    public async Task<IActionResult> GetCourtRevenue(
        [FromQuery] ManagerDashboardCourtRevenueParams courtRevenueParams)
    {
        var query = new GetCourtRevenueForManagerQuery(courtRevenueParams);
        var result = await mediator.Send(query);

        return Ok(result);
    }

    [HttpGet("orders")]
    [Authorize(Roles = "Manager")]
    public async Task<IActionResult> GetOrders(
        [FromQuery] ManagerDashboardOrderParams orderParams)
    {
        var query = new GetOrdersForManagerQuery(orderParams);
        var result = await mediator.Send(query);

        return Ok(result);
    }
}
