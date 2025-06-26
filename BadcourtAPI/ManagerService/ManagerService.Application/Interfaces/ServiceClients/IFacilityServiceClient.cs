namespace ManagerService.Application.Interfaces.ServiceClients;

public interface IFacilityServiceClient
{
    Task<int> GetTotalFacilitiesAsync(string bearerToken, CancellationToken cancellationToken = default);
}
