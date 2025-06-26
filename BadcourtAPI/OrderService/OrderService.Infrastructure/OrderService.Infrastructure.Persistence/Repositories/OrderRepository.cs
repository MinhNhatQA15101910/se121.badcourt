using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
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

    public async Task<IEnumerable<Order>> GetAllOrdersAsync(OrderParams orderParams, CancellationToken cancellationToken = default)
    {
        var query = context.Orders.AsQueryable();

        // Filter by status
        if (orderParams.State != null)
        {
            query = query.Where(o => o.State.ToString().ToLower() == orderParams.State.ToLower());
        }
        
        return await query.ToListAsync(cancellationToken);
    }

    public async Task<Order?> GetByPaymentIntentIdAsync(string paymentIntentId, CancellationToken cancellationToken = default)
    {
        return await context.Orders
            .Include(o => o.Rating)
            .FirstOrDefaultAsync(o => o.PaymentIntentId == paymentIntentId, cancellationToken);
    }

    public async Task<Order?> GetOrderByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await context.Orders
            .Include(o => o.Rating)
            .FirstOrDefaultAsync(o => o.Id == id, cancellationToken);
    }

    public async Task<PagedList<OrderDto>> GetOrdersAsync(OrderParams orderParams, CancellationToken cancellationToken = default, Guid? userId = null)
    {
        var query = context.Orders.AsQueryable();

        // Filter by userId
        if (userId != null)
        {
            query = query.Where(o => o.UserId == userId);
        }

        // Filter by facilityId
        if (orderParams.FacilityId != null)
        {
            query = query.Where(o => o.FacilityId == orderParams.FacilityId);
        }

        // Filter by courtId
        if (orderParams.CourtId != null)
        {
            query = query.Where(o => o.CourtId == orderParams.CourtId);
        }

        // Filter by status
        if (orderParams.State != null)
        {
            query = query.Where(o => o.State.ToString().ToLower() == orderParams.State.ToLower());
        }

        // Filter by date range
        query = query.Where(o =>
            o.DateTimePeriod.HourFrom >= orderParams.HourFrom &&
            o.DateTimePeriod.HourTo <= orderParams.HourTo
        );

        // Order
        query = orderParams.OrderBy switch
        {
            "createdAt" => orderParams.SortBy == "asc"
                ? query.OrderBy(o => o.CreatedAt)
                : query.OrderByDescending(o => o.CreatedAt),
            "price" => orderParams.SortBy == "asc"
                ? query.OrderBy(o => o.Price)
                : query.OrderByDescending(o => o.Price),
            "state" => orderParams.SortBy == "asc"
                ? query.OrderBy(o => o.State)
                : query.OrderByDescending(o => o.State),
            _ => query.OrderBy(o => o.CreatedAt)
        };

        return await PagedList<OrderDto>.CreateAsync(
            query.ProjectTo<OrderDto>(mapper.ConfigurationProvider),
            orderParams.PageNumber,
            orderParams.PageSize
        );
    }
}
