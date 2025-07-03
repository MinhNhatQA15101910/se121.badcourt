using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetRevenueByHourForAdmin;

public record GetRevenueByHourForAdminQuery(
    AdminDashboardRevenueByHourParams RevenueByHourParams
) : IQuery<List<RevenueByHourDto>>;
