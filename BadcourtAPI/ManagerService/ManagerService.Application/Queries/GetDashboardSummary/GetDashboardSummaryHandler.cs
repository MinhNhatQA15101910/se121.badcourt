
using ManagerService.Application.Extensions;
using ManagerService.Application.Interfaces.ServiceClients;
using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;

namespace ManagerService.Application.Queries.GetDashboardSummary;

public class GetDashboardSummaryHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderServiceClient orderServiceClient,
    ICourtServiceClient courtServiceClient
) : IQueryHandler<GetDashboardSummaryQuery, ManagerDashboardSummaryDto>
{
    public async Task<ManagerDashboardSummaryDto> Handle(GetDashboardSummaryQuery request, CancellationToken cancellationToken)
    {
        var bearerToken = httpContextAccessor.HttpContext.GetBearerToken();

        var totalRevenue = await orderServiceClient.GetTotalRevenueAsync(
            bearerToken, request.SummaryParams, cancellationToken);
        var totalOrders = await orderServiceClient.GetTotalOrdersAsync(
            bearerToken, request.SummaryParams, cancellationToken);
        var totalCustomers = await orderServiceClient.GetTotalCustomersAsync(
            bearerToken, request.SummaryParams, cancellationToken);
        var totalCourts = await courtServiceClient.GetTotalCourtsAsync(
            bearerToken, request.SummaryParams, cancellationToken);

        return new ManagerDashboardSummaryDto
        {
            TotalRevenue = totalRevenue,
            TotalOrders = totalOrders,
            TotalCustomers = totalCustomers,
            TotalCourts = totalCourts
        };
    }
}
