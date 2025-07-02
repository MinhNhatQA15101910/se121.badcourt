using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Queries.GetFacilityRevenueForAdmin;
using OrderService.Core.Application.Queries.GetProvinceRevenueForAdmin;
using OrderService.Core.Application.Queries.GetRevenueStatsForAdmin;
using OrderService.Core.Application.Queries.GetTotalOrdersForAdmin;
using OrderService.Core.Application.Queries.GetTotalRevenueForAdmin;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Presentation.Controllers;

[Route("api/admin-dashboard")]
[ApiController]
[Authorize(Roles = "Admin")]
public class AdminDashboardController(IMediator mediator) : ControllerBase
{
    [HttpGet("total-revenue")]
    public async Task<ActionResult<decimal>> GetTotalRevenue(
        [FromQuery] AdminDashboardSummaryParams summaryParams)
    {
        var query = new GetTotalRevenueForAdminQuery(summaryParams);
        var result = await mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("total-orders")]
    public async Task<ActionResult<decimal>> GetTotalOrders(
        [FromQuery] AdminDashboardSummaryParams summaryParams)
    {
        var query = new GetTotalOrdersForAdminQuery(summaryParams);
        var result = await mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("facility-revenue")]
    public async Task<ActionResult<decimal>> GetFacilityRevenue(
        [FromQuery] AdminDashboardFacilityRevenueParams facilityRevenueParams)
    {
        var query = new GetFacilityRevenueForAdminQuery(facilityRevenueParams);
        var result = await mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("revenue-stats")]
    public async Task<ActionResult<List<RevenueStatDto>>> GetRevenueStats(
        [FromQuery] AdminDashboardRevenueStatParams revenueStatParams)
    {
        var query = new GetRevenueStatsForAdminQuery(revenueStatParams);
        var result = await mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("province-revenue")]
    public async Task<ActionResult<List<ProvinceRevenueDto>>> GetProvinceRevenue(
        [FromQuery] AdminDashboardProvinceRevenueParams provinceRevenueParams)
    {
        var query = new GetProvinceRevenueForAdminQuery(provinceRevenueParams);
        var result = await mediator.Send(query);
        return Ok(result);
    }
}
