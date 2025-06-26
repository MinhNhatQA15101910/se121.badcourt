
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetMonthlyRevenue;

public class GetMonthlyRevenueHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository
) : IQueryHandler<GetMonthlyRevenueQuery, List<RevenueByMonthDto>>
{
    public async Task<List<RevenueByMonthDto>> Handle(GetMonthlyRevenueQuery request, CancellationToken cancellationToken)
    {
        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (roles.Contains("Admin"))
        {
            return await orderRepository.GetMonthlyRevenueAsync(null,
                request.ManagerDashboardMonthlyRevenueParams, cancellationToken);
        }

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        return await orderRepository.GetMonthlyRevenueAsync(userId.ToString(),
            request.ManagerDashboardMonthlyRevenueParams, cancellationToken);
    }
}
