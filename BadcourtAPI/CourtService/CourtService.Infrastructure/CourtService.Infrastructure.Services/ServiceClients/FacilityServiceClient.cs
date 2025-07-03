using System.Net.Http.Json;
using CourtService.Core.Application.Interfaces.ServiceClients;
using CourtService.Infrastructure.Configuration;
using Microsoft.Extensions.Options;
using SharedKernel.DTOs;

namespace CourtService.Infrastructure.Services.ServiceClients;

public class FacilityServiceClient(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : IFacilityServiceClient
{
    public Task<FacilityDto?> GetFacilityByIdAsync(string facilityId, CancellationToken cancellationToken = default)
    {
        var facilityApiEndpoint = $"{config.Value.FacilitiesApi}/api/facilities/{facilityId}";
        return client.GetFromJsonAsync<FacilityDto>(facilityApiEndpoint, cancellationToken: cancellationToken);
    }
}
