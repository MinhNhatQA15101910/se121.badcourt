using SharedKernel.Params;

namespace ManagerService.Application.Interfaces.ServiceClients;

public interface IFacilityServiceClient
{
    Task<int> GetTotalFacilitiesAsync(string bearerToken, ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
}
