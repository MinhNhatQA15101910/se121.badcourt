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
    public async Task<decimal> GetTotalRevenueAsync(string bearerToken, AdminDashboardSummaryParams adminDashboardSummaryParams, CancellationToken cancellationToken = default)
    {
        var apiUrl = $"{apiEndpoints.Value.OrdersAdminDashboardApi}/total-revenue";

        apiUrl += $"?startDate={adminDashboardSummaryParams.StartDate:yyyy-MM-dd}&endDate={adminDashboardSummaryParams.EndDate:yyyy-MM-dd}";

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
