
namespace ManagerService.Application.Interfaces.ServiceClients;

public interface IOrderServiceClient
{
    Task<int> GetTotalCustomersAsync(string bearerToken, CancellationToken cancellationToken = default);
    Task<int> GetTotalOrdersAsync(string bearerToken, CancellationToken cancellationToken = default);
    Task<decimal> GetTotalRevenueAsync(string bearerToken, CancellationToken cancellationToken = default);
}
