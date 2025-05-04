using SharedKernel.DTOs;

namespace CourtService.Core.Application.ApiRepositories;

public interface IFacilityApiRepository
{
    Task<FacilityDto?> GetFacilityByIdAsync(string facilityId);
}
