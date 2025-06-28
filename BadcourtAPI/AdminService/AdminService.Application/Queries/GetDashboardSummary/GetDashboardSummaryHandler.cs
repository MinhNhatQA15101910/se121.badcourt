using AdminService.Application.Extensions;
using AdminService.Application.Interfaces.ServiceClients;
using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;

namespace AdminService.Application.Queries.GetDashboardSummary;

public class GetDashboardSummaryHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderServiceClient orderServiceClient
) : IQueryHandler<GetDashboardSummaryQuery, AdminDashboardSummaryDto>
{
    public async Task<AdminDashboardSummaryDto> Handle(GetDashboardSummaryQuery request, CancellationToken cancellationToken)
    {
        var bearerToken = httpContextAccessor.HttpContext.GetBearerToken();

        var totalRevenue = await orderServiceClient.GetTotalRevenueAsync(
            bearerToken, request.Params, cancellationToken);

        return new AdminDashboardSummaryDto
        {
            TotalRevenue = totalRevenue
        };
    }
}
