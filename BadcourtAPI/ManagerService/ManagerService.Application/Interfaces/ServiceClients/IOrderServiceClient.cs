
namespace ManagerService.Application.Interfaces.ServiceClients;

public interface IOrderServiceClient
{
    Task<decimal> GetTotalRevenueAsync(string bearerToken, CancellationToken cancellationToken = default);
}
