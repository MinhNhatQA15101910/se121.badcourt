using SharedKernel.Params;

namespace CourtService.Core.Application.Queries;

public record GetTotalCourtsForManagerQuery(ManagerDashboardSummaryParams Params) : IQuery<int>;
