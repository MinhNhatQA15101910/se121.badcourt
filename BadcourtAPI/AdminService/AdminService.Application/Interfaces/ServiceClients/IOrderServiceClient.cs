using SharedKernel.Params;

namespace AdminService.Application.Interfaces.ServiceClients;

public interface IOrderServiceClient
{
    Task<decimal> GetTotalRevenueForAdminAsync(string bearerToken, AdminDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
}
