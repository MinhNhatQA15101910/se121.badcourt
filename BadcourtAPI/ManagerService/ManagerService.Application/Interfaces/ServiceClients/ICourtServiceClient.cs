using SharedKernel.Params;

namespace ManagerService.Application.Interfaces.ServiceClients;

public interface ICourtServiceClient
{
    Task<int> GetTotalCourtsAsync(string bearerToken, ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
}
