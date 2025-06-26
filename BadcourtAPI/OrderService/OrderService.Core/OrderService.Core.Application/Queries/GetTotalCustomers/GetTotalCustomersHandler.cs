
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;

namespace OrderService.Core.Application.Queries.GetTotalCustomers;

public class GetTotalCustomersHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository
) : IQueryHandler<GetTotalCustomersQuery, int>
{
    public Task<int> Handle(GetTotalCustomersQuery request, CancellationToken cancellationToken)
    {
        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (roles.Contains("Admin"))
        {
            return orderRepository.GetTotalCustomersAsync(null, request.Year, cancellationToken);
        }

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        return orderRepository.GetTotalCustomersAsync(userId.ToString(), request.Year, cancellationToken);
    }
}
