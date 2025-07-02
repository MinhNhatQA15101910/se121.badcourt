using AdminService.Application.Queries.GetDashboardSummary;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AdminService.Presentation.Controllers;

[Route("api/admin-dashboard")]
[ApiController]
public class AdminDashboardController(IMediator mediator) : ControllerBase
{
    [HttpGet("summary")]
    public async Task<ActionResult<AdminDashboardSummaryDto>> GetDashboardSummary(
        [FromQuery] AdminDashboardSummaryParams summaryParams
    )
    {
        var query = new GetDashboardSummaryQuery(summaryParams);
        var result = await mediator.Send(query);
        return Ok(result);
    }
}
