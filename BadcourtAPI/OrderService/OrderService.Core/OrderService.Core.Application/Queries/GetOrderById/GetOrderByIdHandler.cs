using AutoMapper;
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Queries.GetOrderById;

public class GetOrderByIdHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository,
    IMapper mapper
) : IQueryHandler<GetOrderByIdQuery, OrderDto>
{
    public async Task<OrderDto> Handle(GetOrderByIdQuery request, CancellationToken cancellationToken)
    {
        var order = await orderRepository.GetOrderByIdAsync(request.Id, cancellationToken)
            ?? throw new OrderNotFoundException(request.Id);;

        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (!roles.Contains("Admin"))
        {
            var userId = httpContextAccessor.HttpContext.User.GetUserId();
            if (order.UserId != userId)
            {
                throw new ForbiddenAccessException("You do not have permission to access this order.");
            }
        }

        return mapper.Map<OrderDto>(order);
    }
}
