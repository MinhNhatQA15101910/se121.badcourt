using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetRevenueStatsForAdmin;

public record GetRevenueStatsForAdminQuery(
    AdminDashboardRevenueStatParams RevenueStatParams
) : IQuery<List<RevenueStatDto>>;
