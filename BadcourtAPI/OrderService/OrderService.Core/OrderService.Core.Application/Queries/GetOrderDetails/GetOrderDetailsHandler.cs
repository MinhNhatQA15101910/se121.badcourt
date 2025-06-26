using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetOrderDetails;

public class GetOrderDetailsHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository
) : IQueryHandler<GetOrderDetailsQuery, PagedList<OrderDto>>
{
    public async Task<PagedList<OrderDto>> Handle(GetOrderDetailsQuery request, CancellationToken cancellationToken)
    {
        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (roles.Contains("Admin"))
        {
            return await orderRepository.GetOrderDetailsAsync(null, request.OrderParams, cancellationToken);
        }

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        return await orderRepository.GetOrderDetailsAsync(
            userId.ToString(), request.OrderParams, cancellationToken);
    }
}
