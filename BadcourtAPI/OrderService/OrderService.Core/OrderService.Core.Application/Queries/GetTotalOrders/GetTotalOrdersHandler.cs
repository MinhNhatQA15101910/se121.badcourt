
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;

namespace OrderService.Core.Application.Queries.GetTotalOrders;

public class GetTotalOrdersHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository
) : IQueryHandler<GetTotalOrdersQuery, int>
{
    public Task<int> Handle(GetTotalOrdersQuery request, CancellationToken cancellationToken)
    {
        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (roles.Contains("Admin"))
        {
            return orderRepository.GetTotalOrdersAsync(null, request.Year, cancellationToken);
        }

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        return orderRepository.GetTotalOrdersAsync(userId.ToString(), request.Year, cancellationToken);
    }
}
