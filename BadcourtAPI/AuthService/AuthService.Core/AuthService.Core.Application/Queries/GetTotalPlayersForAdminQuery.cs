using SharedKernel.Params;

namespace AuthService.Core.Application.Queries;

public record GetTotalPlayersForAdminQuery(
    AdminDashboardSummaryParams SummaryParams
) : IQuery<int>;
