using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetTotalCustomersForManager;

public record GetTotalCustomersForManagerQuery(
    ManagerDashboardSummaryParams SummaryParams
) : IQuery<int>;
