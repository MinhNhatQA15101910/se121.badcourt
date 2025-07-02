using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetTotalOrdersForManager;

public record GetTotalOrdersForManagerQuery(
    ManagerDashboardSummaryParams SummaryParams
) : IQuery<int>;
