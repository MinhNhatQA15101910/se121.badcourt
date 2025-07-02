using AuthService.Core.Application.Queries;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AuthService.Presentation.Controllers;

[Route("api/admin-dashboard")]
[ApiController]
[Authorize(Roles = "Admin")]
public class AdminDashboardController(IMediator mediator) : ControllerBase
{
    [HttpGet("total-players")]
    public async Task<ActionResult<int>> GetTotalPlayers(
        [FromQuery] AdminDashboardSummaryParams summaryParams)
    {
        var query = new GetTotalPlayersForAdminQuery(summaryParams);
        var result = await mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("total-managers")]
    public async Task<ActionResult<int>> GetTotalManagers(
        [FromQuery] AdminDashboardSummaryParams summaryParams)
    {
        var query = new GetTotalManagersForAdminQuery(summaryParams);
        var result = await mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("total-new-players")]
    public async Task<ActionResult<int>> GetTotalNewPlayers()
    {
        var query = new GetTotalNewPlayersForAdminQuery();
        var result = await mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("total-new-managers")]
    public async Task<ActionResult<int>> GetTotalNewManagers()
    {
        var query = new GetTotalNewManagersForAdminQuery();
        var result = await mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("user-stats")]
    public async Task<ActionResult<List<UserStatDto>>> GetUserStats([FromQuery] AdminDashboardUserStatParams userStatParams)
    {
        var query = new GetUserStatsForAdminQuery(userStatParams);
        var result = await mediator.Send(query);
        return Ok(result);
    }
}
