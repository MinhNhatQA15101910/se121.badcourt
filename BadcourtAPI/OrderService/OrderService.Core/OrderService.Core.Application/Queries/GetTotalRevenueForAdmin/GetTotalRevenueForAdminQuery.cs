using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetTotalRevenueForAdmin;

public record GetTotalRevenueForAdminQuery(
    AdminDashboardSummaryParams SummaryParams
) : IQuery<decimal>;
