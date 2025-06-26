using System.Net.Http.Headers;
using System.Net.Http.Json;
using ManagerService.Application.Interfaces.ServiceClients;
using ManagerService.Infrastructure.Services.Configurations;
using Microsoft.Extensions.Options;
using SharedKernel.Params;

namespace ManagerService.Infrastructure.Services.ServiceClients;

public class FacilityServiceClient(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : IFacilityServiceClient
{
    public Task<int> GetTotalFacilitiesAsync(string bearerToken, ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default)
    {
        var apiUrl = config.Value.FacilitiesApi;
        apiUrl += "/total-facilities";
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
            throw new Exception($"Failed to get total facilities: {response.ReasonPhrase}");
        }

        return response.Content.ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
    }
}
