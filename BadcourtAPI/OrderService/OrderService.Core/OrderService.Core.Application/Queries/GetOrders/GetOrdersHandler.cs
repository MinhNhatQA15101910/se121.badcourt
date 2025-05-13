using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetOrders;

public class GetOrdersHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository
) : IQueryHandler<GetOrdersQuery, PagedList<OrderDto>>
{
    public async Task<PagedList<OrderDto>> Handle(GetOrdersQuery request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (!roles.Contains("Admin"))
        {
            return await orderRepository.GetOrdersAsync(request.OrderParams, cancellationToken, userId);
        }

        return await orderRepository.GetOrdersAsync(request.OrderParams, cancellationToken);
    }
}
