using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetMonthlyRevenue;

public record GetMonthlyRevenueQuery(
    ManagerDashboardMonthlyRevenueParams ManagerDashboardMonthlyRevenueParams) : IQuery<List<RevenueByMonthDto>>;
