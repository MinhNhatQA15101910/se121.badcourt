using System.Net.Http.Headers;
using System.Net.Http.Json;
using CourtService.Core.Application.Interfaces.ServiceClients;
using CourtService.Infrastructure.Configuration;
using Microsoft.Extensions.Options;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace CourtService.Infrastructure.Services.ServiceClients;

public class OrderServiceClient(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : IOrderServiceClient
{
    public async Task<IEnumerable<OrderDto>?> GetOrdersAsync(OrderParams orderParams, CancellationToken cancellationToken = default)
    {
        var orderApiEndpoint = $"{config.Value.OrdersApi}/api/orders";
        var query = $"{orderApiEndpoint}?pageNumber={orderParams.PageNumber}&pageSize={orderParams.PageSize}";
        if (!string.IsNullOrEmpty(orderParams.FacilityId))
        {
            query += $"&facilityId={orderParams.FacilityId}";
        }
        if (!string.IsNullOrEmpty(orderParams.CourtId))
        {
            query += $"&courtId={orderParams.CourtId}";
        }
        if (!string.IsNullOrEmpty(orderParams.State))
        {
            query += $"&state={orderParams.State}";
        }
        query += $"&hourFrom={orderParams.HourFrom:O}&hourTo={orderParams.HourTo:O}";
        query += $"&orderBy={orderParams.OrderBy}&sortBy={orderParams.SortBy}";

        using var request = new HttpRequestMessage(HttpMethod.Get, query);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", config.Value.AccessToken);

        using var response = await client.SendAsync(request);
        response.EnsureSuccessStatusCode();

        return await response.Content.ReadFromJsonAsync<IEnumerable<OrderDto>>(cancellationToken: cancellationToken);
    }
}
