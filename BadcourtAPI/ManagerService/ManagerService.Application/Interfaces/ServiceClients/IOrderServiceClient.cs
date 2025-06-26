
namespace ManagerService.Application.Interfaces.ServiceClients;

public interface IOrderServiceClient
{
    Task<decimal> GetTotalRevenueAsync(string userId, CancellationToken cancellationToken = default);
}
