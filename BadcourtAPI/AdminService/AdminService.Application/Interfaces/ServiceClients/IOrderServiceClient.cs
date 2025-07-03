using SharedKernel.Params;

namespace AdminService.Application.Interfaces.ServiceClients;

public interface IOrderServiceClient
{
    Task<int> GetTotalOrdersForAdminAsync(
        string bearerToken, AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default);
    Task<decimal> GetTotalRevenueForAdminAsync(string bearerToken, AdminDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
}
