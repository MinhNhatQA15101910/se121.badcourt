using System.Net.Http.Headers;
using System.Net.Http.Json;
using ManagerService.Application.Interfaces.ServiceClients;
using ManagerService.Infrastructure.Services.Configurations;
using Microsoft.Extensions.Options;
using SharedKernel.Params;

namespace ManagerService.Infrastructure.Services.ServiceClients;

public class OrderServiceClient(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : IOrderServiceClient
{
    public Task<int> GetTotalCustomersAsync(string bearerToken, ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default)
    {
        var apiUrl = config.Value.OrdersApi;
        apiUrl += "/total-customers";
        if (summaryParams.Year.HasValue)
        {
            // Append the year as a query parameter if provided
            apiUrl += $"?year={summaryParams.Year.Value}";
        }

        var request = new HttpRequestMessage(HttpMethod.Get, apiUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        var response = client.SendAsync(request, cancellationToken).Result;

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception($"Failed to get total customers: {response.ReasonPhrase}");
        }

        return response.Content.ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
    }

    public Task<int> GetTotalOrdersAsync(string bearerToken, ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default)
    {
        var apiUrl = config.Value.OrdersApi;
        apiUrl += "/total-orders";
        if (summaryParams.Year.HasValue)
        {
            // Append the year as a query parameter if provided
            apiUrl += $"?year={summaryParams.Year.Value}";
        }

        var request = new HttpRequestMessage(HttpMethod.Get, apiUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        var response = client.SendAsync(request, cancellationToken).Result;

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception($"Failed to get total orders: {response.ReasonPhrase}");
        }

        return response.Content.ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
    }

    public async Task<decimal> GetTotalRevenueAsync(string bearerToken, ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default)
    {
        var apiUrl = config.Value.OrdersApi;
        apiUrl += "/total-revenue";
        if (summaryParams.Year.HasValue)
        {
            // Append the year as a query parameter if provided
            apiUrl += $"?year={summaryParams.Year.Value}";
        }

        var request = new HttpRequestMessage(HttpMethod.Get, apiUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        var response = await client.SendAsync(request, cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception($"Failed to get total revenue: {response.ReasonPhrase}");
        }

        return await response.Content.ReadFromJsonAsync<decimal>(cancellationToken: cancellationToken);
    }
}
