using SharedKernel.Params;

namespace AdminService.Application.Interfaces.ServiceClients;

public interface IOrderServiceClient
{
    Task<decimal> GetTotalRevenueForAdminAsync(string bearerToken, AdminDashboardSummaryParams adminDashboardSummaryParams,
        CancellationToken cancellationToken = default);
}
