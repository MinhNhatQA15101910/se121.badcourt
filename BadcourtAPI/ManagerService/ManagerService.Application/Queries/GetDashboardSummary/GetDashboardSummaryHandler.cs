
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
        var bearerToken = httpContextAccessor.HttpContext?.GetBearerToken();
        
        var totalRevenue = await orderServiceClient.GetTotalRevenueAsync(bearerToken!, cancellationToken);
        var totalOrders = await orderServiceClient.GetTotalOrdersAsync(bearerToken!, cancellationToken);
        var totalCustomers = await orderServiceClient.GetTotalCustomersAsync(bearerToken!, cancellationToken);

        return new DashboardSummaryResponse
        {
            TotalRevenue = totalRevenue,
            TotalOrders = totalOrders,
            TotalCustomers = totalCustomers
        };
    }
}
