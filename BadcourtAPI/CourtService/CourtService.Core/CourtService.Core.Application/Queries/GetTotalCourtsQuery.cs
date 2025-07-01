using SharedKernel.Params;

namespace CourtService.Core.Application.Queries;

public record GetTotalCourtsQuery(ManagerDashboardSummaryParams Params) : IQuery<int>;
