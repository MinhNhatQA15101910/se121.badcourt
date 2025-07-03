using System.Net.Http.Headers;
using System.Net.Http.Json;
using AdminService.Application.Interfaces.ServiceClients;
using AdminService.Infrastructure.Services.Configurations;
using Microsoft.Extensions.Options;
using SharedKernel.Params;

namespace AdminService.Infrastructure.Services.ServiceClients;

public class OrderServiceClient(
    HttpClient client,
    IOptions<ApiEndpoints> apiEndpoints
) : IOrderServiceClient
{
    public Task<int> GetTotalOrdersForAdminAsync(string bearerToken, AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default)
    {
        var apiUrl = $"{apiEndpoints.Value.OrdersApi}/api/admin-dashboard/total-orders";

        apiUrl += $"?startDate={summaryParams.StartDate:yyyy-MM-dd}&endDate={summaryParams.EndDate:yyyy-MM-dd}";

        var request = new HttpRequestMessage(HttpMethod.Get, apiUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        return client.SendAsync(request, cancellationToken)
            .ContinueWith(responseTask =>
            {
                var response = responseTask.Result;
                if (!response.IsSuccessStatusCode)
                {
                    throw new Exception($"Failed to get total orders: {response.ReasonPhrase}");
                }
                return response.Content.ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
            }, cancellationToken).Unwrap();
    }

    public async Task<decimal> GetTotalRevenueForAdminAsync(
        string bearerToken, AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default)
    {
        var apiUrl = $"{apiEndpoints.Value.OrdersApi}/api/admin-dashboard/total-revenue";

        apiUrl += $"?startDate={summaryParams.StartDate:yyyy-MM-dd}&endDate={summaryParams.EndDate:yyyy-MM-dd}";

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
