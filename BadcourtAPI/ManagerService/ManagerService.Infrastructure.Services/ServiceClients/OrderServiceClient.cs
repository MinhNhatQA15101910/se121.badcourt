using System.Net.Http.Json;
using ManagerService.Application.Interfaces.ServiceClients;
using ManagerService.Infrastructure.Services.Configurations;
using Microsoft.Extensions.Options;

namespace ManagerService.Infrastructure.Services.ServiceClients;

public class OrderServiceClient(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : IOrderServiceClient
{
    public async Task<decimal> GetTotalRevenueAsync(string userId, CancellationToken cancellationToken = default)
    {
        var orderApiEndpoint = config.Value.OrdersApi;
        return await client.GetFromJsonAsync<decimal>($"{orderApiEndpoint}/total-revenue", cancellationToken: cancellationToken);
    }
}
