using SharedKernel.Params;

namespace AdminService.Application.Interfaces.ServiceClients;

public interface IUserServiceClient
{
    Task<int> GetTotalManagersForAdminAsync(
        string bearerToken, AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default);
    Task<int> GetTotalNewManagersForAdminAsync(
        string bearerToken, CancellationToken cancellationToken = default);
    Task<int> GetTotalNewPlayersForAdminAsync(
        string bearerToken, CancellationToken cancellationToken = default);
    Task<int> GetTotalPlayersForAdminAsync(
        string bearerToken, AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default);
}
