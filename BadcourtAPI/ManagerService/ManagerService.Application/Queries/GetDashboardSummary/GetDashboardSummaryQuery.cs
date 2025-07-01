using SharedKernel.DTOs;
using SharedKernel.Params;

namespace ManagerService.Application.Queries.GetDashboardSummary;

public record GetDashboardSummaryQuery(
    ManagerDashboardSummaryParams SummaryParams
) : IQuery<ManagerDashboardSummaryDto>;
