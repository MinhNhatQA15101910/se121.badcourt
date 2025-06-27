using SharedKernel.Params;

namespace AdminService.Application.Interfaces.ServiceClients;

public interface IOrderServiceClient
{
    Task<decimal> GetTotalRevenueAsync(string bearerToken, AdminDashboardSummaryParams adminDashboardSummaryParams,
        CancellationToken cancellationToken = default);
}
