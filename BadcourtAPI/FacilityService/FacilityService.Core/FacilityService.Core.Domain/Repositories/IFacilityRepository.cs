using FacilityService.Core.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace FacilityService.Core.Domain.Repositories;

public interface IFacilityRepository
{
    Task AddFacilityAsync(Facility facility, CancellationToken cancellationToken = default);
    Task<bool> AnyAsync(CancellationToken cancellationToken = default);
    Task<PagedList<FacilityDto>> GetFacilitiesAsync(FacilityParams facilityParams, CancellationToken cancellationToken = default);
    Task<Facility?> GetFacilityByIdAsync(string id, CancellationToken cancellationToken = default);
    Task<List<string>> GetFacilityProvincesAsync(CancellationToken cancellationToken);
    Task InsertManyAsync(IEnumerable<Facility> facilities, CancellationToken cancellationToken = default);
    Task DeleteFacilityAsync(Facility facility, CancellationToken cancellationToken = default);
    Task UpdateFacilityAsync(Facility facility, CancellationToken cancellationToken = default);
    Task<int> GetTotalFacilitiesAsync(string? userId, int? year, CancellationToken cancellationToken = default);
    Task<List<Facility>> GetAllFacilitiesAsync(FacilityParams facilityParams, CancellationToken cancellationToken = default);
}
