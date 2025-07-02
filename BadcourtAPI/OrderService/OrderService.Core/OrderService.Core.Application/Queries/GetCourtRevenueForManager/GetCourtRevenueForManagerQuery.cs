using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetCourtRevenueForManager;

public record GetCourtRevenueForManagerQuery(
    ManagerDashboardCourtRevenueParams CourtRevenueParams
) : IQuery<List<CourtRevenueDto>>;
