using System.Net.Http.Json;
using SharedKernel.DTOs;

namespace CourtService.Core.Application.ApiRepositories;

public class FacilityApiRepository(
    ApiEndpoints apiEndpoints,
    HttpClient client
    ) : IFacilityApiRepository
{
    private readonly string facilityApiEndpoint = apiEndpoints.GetFacilitiesApi();

    public async Task<FacilityDto?> GetFacilityByIdAsync(string facilityId, CancellationToken cancellationToken = default)
    {
        return await client.GetFromJsonAsync<FacilityDto>($"{facilityApiEndpoint}/{facilityId}", cancellationToken: cancellationToken);
    }
}
