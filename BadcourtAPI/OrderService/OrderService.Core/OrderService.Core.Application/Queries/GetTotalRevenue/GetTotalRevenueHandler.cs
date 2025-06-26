
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;

namespace OrderService.Core.Application.Queries.GetTotalRevenue;

public class GetTotalRevenueHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository
) : IQueryHandler<GetTotalRevenueQuery, decimal>
{
    public async Task<decimal> Handle(GetTotalRevenueQuery request, CancellationToken cancellationToken)
    {
        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (roles.Contains("Admin"))
        {
            return await orderRepository.GetTotalRevenueAsync(null, cancellationToken);
        }

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        return await orderRepository.GetTotalRevenueAsync(userId.ToString(), cancellationToken);
    }
}
