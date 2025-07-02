using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetTotalRevenueForManager;

public record GetTotalRevenueForManagerQuery(
    ManagerDashboardSummaryParams SummaryParams
) : IQuery<decimal>;
