using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetFacilityRevenueForAdmin;

public record GetFacilityRevenueForAdminQuery(
    AdminDashboardFacilityRevenueParams FacilityRevenueParams
) : IQuery<List<FacilityRevenueDto>>;
