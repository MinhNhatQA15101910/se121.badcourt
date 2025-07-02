using SharedKernel.Params;

namespace AdminService.Application.Interfaces.ServiceClients;

public interface IUserServiceClient
{
    Task<int> GetTotalPlayersForAdminAsync(
        string bearerToken, AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken);
}
