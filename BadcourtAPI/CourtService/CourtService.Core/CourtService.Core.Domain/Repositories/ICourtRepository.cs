using CourtService.Core.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace CourtService.Core.Domain.Repositories;

public interface ICourtRepository
{
    Task AddCourtAsync(Court court, CancellationToken cancellationToken = default);
    Task<bool> AnyAsync(CancellationToken cancellationToken = default);
    Task DeleteCourtAsync(Court court, CancellationToken cancellationToken = default);
    Task<List<Court>> GetAllCourtAsync(CourtParams courtParams, CancellationToken cancellationToken = default);
    Task<Court?> GetCourtByIdAsync(string id, CancellationToken cancellationToken = default);
    Task<Court?> GetCourtByNameAsync(string courtName, string facilityId, CancellationToken cancellationToken = default);
    Task<PagedList<CourtDto>> GetCourtsAsync(CourtParams courtParams, CancellationToken cancellationToken = default);
    Task<decimal> GetFacilityMaxPriceAsync(string facilityId, CancellationToken cancellationToken = default);
    Task<decimal> GetFacilityMinPriceAsync(string facilityId, CancellationToken cancellationToken = default);
    Task<int> GetTotalCourtsForFacilityAsync(ManagerDashboardSummaryParams @params, CancellationToken cancellationToken = default);
    Task UpdateCourtAsync(Court court, CancellationToken cancellationToken = default);
}
