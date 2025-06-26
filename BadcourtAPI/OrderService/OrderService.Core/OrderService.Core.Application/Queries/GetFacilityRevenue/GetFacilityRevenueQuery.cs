using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetFacilityRevenue;

public record GetFacilityRevenueQuery(
    ManagerDashboardFacilityRevenueParams ManagerDashboardFacilityRevenueParams) : IQuery<List<FacilityRevenueDto>>;
