using AdminService.Application.Extensions;
using AdminService.Application.Interfaces.ServiceClients;
using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;

namespace AdminService.Application.Queries.GetDashboardSummary;

public class GetDashboardSummaryHandler(
    IHttpContextAccessor httpContextAccessor,
    IUserServiceClient userServiceClient,
    IOrderServiceClient orderServiceClient
) : IQueryHandler<GetDashboardSummaryQuery, AdminDashboardSummaryDto>
{
    public async Task<AdminDashboardSummaryDto> Handle(GetDashboardSummaryQuery request, CancellationToken cancellationToken)
    {
        var bearerToken = httpContextAccessor.HttpContext.GetBearerToken();

        var totalRevenue = await orderServiceClient.GetTotalRevenueForAdminAsync(
            bearerToken, request.SummaryParams, cancellationToken);
        var totalPlayers = await userServiceClient.GetTotalPlayersForAdminAsync(
            bearerToken, request.SummaryParams, cancellationToken);
        var totalManagers = await userServiceClient.GetTotalManagersForAdminAsync(
            bearerToken, request.SummaryParams, cancellationToken);
        var totalNewPlayers = await userServiceClient.GetTotalNewPlayersForAdminAsync(
            bearerToken, cancellationToken);
        var totalNewManagers = await userServiceClient.GetTotalNewManagersForAdminAsync(
            bearerToken, cancellationToken);
        var totalOrders = await orderServiceClient.GetTotalOrdersForAdminAsync(
            bearerToken, request.SummaryParams, cancellationToken);

        return new AdminDashboardSummaryDto
        {
            TotalRevenue = totalRevenue,
            TotalPlayers = totalPlayers,
            TotalManagers = totalManagers,
            NewPlayers = totalNewPlayers,
            NewManagers = totalNewManagers,
            TotalOrders = totalOrders
        };
    }
}
