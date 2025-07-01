using System.Net.Http.Json;
using Microsoft.Extensions.Options;
using OrderService.Infrastructure.Configuration;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.ApiRepository;

public class FacilityApiRepository(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : IFacilityApiRepository
{
    public async Task<FacilityDto?> GetFacilityByIdAsync(string facilityId, CancellationToken cancellationToken = default)
    {
        var facilityApiEndpoint = config.Value.FacilitiesApi;
        return await client.GetFromJsonAsync<FacilityDto>($"{facilityApiEndpoint}/{facilityId}", cancellationToken: cancellationToken);
    }
}
