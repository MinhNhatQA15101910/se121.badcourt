
using SharedKernel.Params;

namespace ManagerService.Application.Interfaces.ServiceClients;

public interface IOrderServiceClient
{
    Task<int> GetTotalCustomersAsync(string bearerToken, ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
    Task<int> GetTotalOrdersAsync(string bearerToken, ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
    Task<decimal> GetTotalRevenueAsync(string bearerToken, ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
}
