using System.Net.Http.Headers;
using System.Net.Http.Json;
using AdminService.Application.Interfaces.ServiceClients;
using AdminService.Infrastructure.Services.Configurations;
using Microsoft.Extensions.Options;
using SharedKernel.Params;

namespace AdminService.Infrastructure.Services.ServiceClients;

public class UserServiceClient(
    HttpClient client,
    IOptions<ApiEndpoints> apiEndpoints
) : IUserServiceClient
{
    public Task<int> GetTotalManagersForAdminAsync(string bearerToken, AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default)
    {
        var apiUrl = $"{apiEndpoints.Value.UsersApi}/api/admin-dashboard/total-managers";

        apiUrl += $"?startDate={summaryParams.StartDate:yyyy-MM-dd}&endDate={summaryParams.EndDate:yyyy-MM-dd}";

        var request = new HttpRequestMessage(HttpMethod.Get, apiUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        return client.SendAsync(request, cancellationToken)
            .ContinueWith(responseTask =>
            {
                var response = responseTask.Result;
                if (!response.IsSuccessStatusCode)
                {
                    throw new Exception($"Failed to get total managers: {response.ReasonPhrase}");
                }
                return response.Content.ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
            }, cancellationToken).Unwrap();
    }

    public Task<int> GetTotalNewManagersForAdminAsync(string bearerToken, CancellationToken cancellationToken = default)
    {
        var apiUrl = $"{apiEndpoints.Value.UsersApi}/api/admin-dashboard/total-new-managers";

        var request = new HttpRequestMessage(HttpMethod.Get, apiUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        return client.SendAsync(request, cancellationToken)
            .ContinueWith(responseTask =>
            {
                var response = responseTask.Result;
                if (!response.IsSuccessStatusCode)
                {
                    throw new Exception($"Failed to get total new managers: {response.ReasonPhrase}");
                }
                return response.Content.ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
            }, cancellationToken).Unwrap();
    }

    public Task<int> GetTotalNewPlayersForAdminAsync(string bearerToken, CancellationToken cancellationToken = default)
    {
        var apiUrl = $"{apiEndpoints.Value.UsersApi}/api/admin-dashboard/total-new-players";

        var request = new HttpRequestMessage(HttpMethod.Get, apiUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        return client.SendAsync(request, cancellationToken)
            .ContinueWith(responseTask =>
            {
                var response = responseTask.Result;
                if (!response.IsSuccessStatusCode)
                {
                    throw new Exception($"Failed to get total new players: {response.ReasonPhrase}");
                }
                return response.Content.ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
            }, cancellationToken).Unwrap();
    }

    public async Task<int> GetTotalPlayersForAdminAsync(
        string bearerToken, AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default)
    {
        var apiUrl = $"{apiEndpoints.Value.UsersApi}/api/admin-dashboard/total-players";

        apiUrl += $"?startDate={summaryParams.StartDate:yyyy-MM-dd}&endDate={summaryParams.EndDate:yyyy-MM-dd}";

        var request = new HttpRequestMessage(HttpMethod.Get, apiUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);

        var response = await client.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            throw new Exception($"Failed to get total players: {response.ReasonPhrase}");
        }

        return await response.Content.ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
    }
}
