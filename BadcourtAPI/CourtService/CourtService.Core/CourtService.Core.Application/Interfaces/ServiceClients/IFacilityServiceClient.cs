using SharedKernel.DTOs;

namespace CourtService.Core.Application.Interfaces.ServiceClients;

public interface IFacilityServiceClient
{
    Task<FacilityDto?> GetFacilityByIdAsync(
        string facilityId, CancellationToken cancellationToken = default);
}
