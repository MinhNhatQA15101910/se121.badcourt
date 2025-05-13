using AutoMapper;
using AutoMapper.QueryableExtensions;
using OrderService.Core.Domain.Entities;
using OrderService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Infrastructure.Persistence.Repositories;

public class OrderRepository(
    DataContext context,
    IMapper mapper
) : IOrderRepository
{
    public void AddOrder(Order order)
    {
        context.Orders.Add(order);
    }

    public async Task<bool> CompleteAsync(CancellationToken cancellationToken = default)
    {
        return await context.SaveChangesAsync(cancellationToken) > 0;
    }

    public async Task<Order?> GetOrderByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await context.Orders.FindAsync([id, cancellationToken], cancellationToken: cancellationToken);
    }

    public async Task<PagedList<OrderDto>> GetOrdersAsync(OrderParams orderParams, CancellationToken cancellationToken = default, Guid? userId = null)
    {
        var query = context.Orders.AsQueryable();

        // Filter by userId
        if (userId != null)
        {
            query = query.Where(o => o.UserId == userId);
        }

        // Filter by courtId
        if (orderParams.CourtId != null)
        {
            query = query.Where(o => o.CourtId == orderParams.CourtId);
        }

        // Filter by status
        if (orderParams.OrderState != null)
        {
            query = query.Where(o => o.State.ToString().Equals(orderParams.OrderState, StringComparison.CurrentCultureIgnoreCase));
        }

        // Order
        query = orderParams.OrderBy switch
        {
            "createdAt" => orderParams.SortBy == "asc"
                        ? query.OrderBy(o => o.CreatedAt)
                        : query.OrderByDescending(o => o.CreatedAt),
            _ => query.OrderBy(o => o.CreatedAt)
        };

        return await PagedList<OrderDto>.CreateAsync(
            query.ProjectTo<OrderDto>(mapper.ConfigurationProvider),
            orderParams.PageNumber,
            orderParams.PageSize
        );
    }
}
