using SharedKernel.DTOs;

namespace OrderService.Core.Application.ApiRepository;

public interface IFacilityApiRepository
{
    Task<FacilityDto?> GetFacilityByIdAsync(string facilityId, CancellationToken cancellationToken = default);
}
