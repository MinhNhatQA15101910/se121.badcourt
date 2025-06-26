using System.Net.Http.Headers;
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
    public Task<int> GetTotalOrdersAsync(string bearerToken, CancellationToken cancellationToken = default)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, config.Value.OrdersApi + "/total-orders");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        var response = client.SendAsync(request, cancellationToken).Result;
        
        if (!response.IsSuccessStatusCode)
        {
            throw new Exception($"Failed to get total orders: {response.ReasonPhrase}");
        }

        return response.Content.ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
    }

    public async Task<decimal> GetTotalRevenueAsync(string bearerToken, CancellationToken cancellationToken = default)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, config.Value.OrdersApi + "/total-revenue");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        var response = await client.SendAsync(request, cancellationToken);
        
        if (!response.IsSuccessStatusCode)
        {
            throw new Exception($"Failed to get total revenue: {response.ReasonPhrase}");
        }

        return await response.Content.ReadFromJsonAsync<decimal>(cancellationToken: cancellationToken);
    }
}
