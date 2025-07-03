using SharedKernel.Params;

namespace AuthService.Core.Application.Queries;

public record GetTotalManagersForAdminQuery(
    AdminDashboardSummaryParams SummaryParams
) : IQuery<int>;
