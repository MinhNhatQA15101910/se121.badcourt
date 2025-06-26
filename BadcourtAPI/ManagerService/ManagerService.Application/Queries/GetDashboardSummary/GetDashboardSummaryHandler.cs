
using ManagerService.Application.Extensions;
using ManagerService.Application.Interfaces.ServiceClients;
using Microsoft.AspNetCore.Http;

namespace ManagerService.Application.Queries.GetDashboardSummary;

public class GetDashboardSummaryHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderServiceClient orderServiceClient
) : IQueryHandler<GetDashboardSummaryQuery, DashboardSummaryResponse>
{
    public async Task<DashboardSummaryResponse> Handle(GetDashboardSummaryQuery request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        
        var totalRevenue = await orderServiceClient.GetTotalRevenueAsync(userId, cancellationToken);

        return new DashboardSummaryResponse
        {
            TotalRevenue = totalRevenue
        };
    }
}
