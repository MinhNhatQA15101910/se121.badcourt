using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetTotalOrdersForAdmin;

public record GetTotalOrdersForAdminQuery(
    AdminDashboardSummaryParams SummaryParams
) : IQuery<int>;
