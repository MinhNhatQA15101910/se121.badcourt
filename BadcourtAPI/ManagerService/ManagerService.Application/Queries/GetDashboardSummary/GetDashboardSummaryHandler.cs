
using ManagerService.Application.Extensions;
using ManagerService.Application.Interfaces.ServiceClients;
using Microsoft.AspNetCore.Http;

namespace ManagerService.Application.Queries.GetDashboardSummary;

public class GetDashboardSummaryHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderServiceClient orderServiceClient,
    IFacilityServiceClient facilityServiceClient
) : IQueryHandler<GetDashboardSummaryQuery, DashboardSummaryResponse>
{
    public async Task<DashboardSummaryResponse> Handle(GetDashboardSummaryQuery request, CancellationToken cancellationToken)
    {
        var bearerToken = httpContextAccessor.HttpContext.GetBearerToken();

        var totalRevenue = await orderServiceClient.GetTotalRevenueAsync(
            bearerToken, request.SummaryParams, cancellationToken);
        var totalOrders = await orderServiceClient.GetTotalOrdersAsync(
            bearerToken, request.SummaryParams, cancellationToken);
        var totalCustomers = await orderServiceClient.GetTotalCustomersAsync(
            bearerToken, request.SummaryParams, cancellationToken);
        var totalFacilities = await facilityServiceClient.GetTotalFacilitiesAsync(
            bearerToken, request.SummaryParams, cancellationToken);

        return new DashboardSummaryResponse
        {
            TotalRevenue = totalRevenue,
            TotalOrders = totalOrders,
            TotalCustomers = totalCustomers,
            TotalFacilities = totalFacilities
        };
    }
}
