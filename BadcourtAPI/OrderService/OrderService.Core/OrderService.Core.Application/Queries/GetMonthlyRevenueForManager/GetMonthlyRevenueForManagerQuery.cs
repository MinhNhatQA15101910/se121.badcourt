using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetMonthlyRevenueForManager;

public record GetMonthlyRevenueForManagerQuery(
    ManagerDashboardMonthlyRevenueParams Params
) : IQuery<List<RevenueByMonthDto>>;
