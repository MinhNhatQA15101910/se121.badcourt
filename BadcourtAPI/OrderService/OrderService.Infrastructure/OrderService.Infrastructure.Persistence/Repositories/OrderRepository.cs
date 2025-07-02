using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using OrderService.Core.Domain.Entities;
using OrderService.Core.Domain.Enums;
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

    public async Task<List<FacilityRevenueDto>> GetFacilityRevenueAsync(
        string? userId,
        ManagerDashboardFacilityRevenueParams managerDashboardFacilityRevenueParams,
        CancellationToken cancellationToken = default)
    {
        var query = context.Orders.AsQueryable();

        if (userId != null)
        {
            query = query.Where(o => o.FacilityOwnerId == userId);
        }

        // Filter by year
        query = query.Where(o => o.CreatedAt.Year == managerDashboardFacilityRevenueParams.Year);

        // Filter by month
        if (managerDashboardFacilityRevenueParams.Month.HasValue)
        {
            query = query.Where(o => o.CreatedAt.Month == managerDashboardFacilityRevenueParams.Month.Value);
        }

        // Exclude pending orders
        //query = query.Where(o => o.State != OrderState.Pending);

        // Execute grouping and projection
        var groupedData = await query
            .GroupBy(o => o.FacilityId)
            .Select(g => new FacilityRevenueDto
            {
                FacilityId = g.Key,
                FacilityName = g.Select(x => x.FacilityName).FirstOrDefault()!,
                Revenue = g.Sum(x => x.Price)
            })
            .ToListAsync(cancellationToken);

        // Order in-memory to avoid SQLite decimal ordering limitation
        return [.. groupedData.OrderByDescending(r => r.Revenue)];
    }

    public Task<List<RevenueByMonthDto>> GetMonthlyRevenueForManagerAsync(ManagerDashboardMonthlyRevenueParams @params, CancellationToken cancellationToken)
    {
        var query = context.Orders.AsQueryable();

        // Filter by facilityId
        query = query.Where(o => o.FacilityId == @params.FacilityId);

        // Filter by year
        query = query.Where(o => o.CreatedAt.Year == @params.Year);

        // Exclude pending orders
        query = query.Where(o => o.State != OrderState.Pending);

        return query
            .GroupBy(o => new { o.CreatedAt.Year, o.CreatedAt.Month })
            .Select(g => new RevenueByMonthDto
            {
                Month = g.Key.Month,
                Revenue = g.Sum(o => o.Price)
            })
            .OrderBy(r => r.Month)
            .ToListAsync(cancellationToken);
    }

    public async Task<Order?> GetOrderByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await context.Orders
            .Include(o => o.Rating)
            .FirstOrDefaultAsync(o => o.Id == id, cancellationToken);
    }

    public Task<PagedList<OrderDto>> GetOrderDetailsAsync(string? userId, OrderParams orderParams, CancellationToken cancellationToken)
    {
        var query = context.Orders.AsQueryable();

        // Filter by userId
        if (userId != null)
        {
            query = query.Where(o => o.FacilityOwnerId == userId);
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

        return PagedList<OrderDto>.CreateAsync(
            query.ProjectTo<OrderDto>(mapper.ConfigurationProvider),
            orderParams.PageNumber,
            orderParams.PageSize,
            cancellationToken
        );
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

    public Task<int> GetTotalCustomersForFacilityAsync(ManagerDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default)
    {
        var query = context.Orders.AsQueryable();

        // Filter by facilityId
        query = query.Where(o => o.FacilityId == summaryParams.FacilityId);

        // Filter by year
        if (summaryParams.Year.HasValue)
        {
            query = query.Where(o => o.CreatedAt.Year == summaryParams.Year.Value);
        }

        // Exclude pending orders
        query = query.Where(o => o.State != OrderState.Pending);

        // Select distinct user IDs and count them
        return query
            .Select(o => o.UserId)
            .Distinct()
            .CountAsync(cancellationToken);
    }

    public Task<int> GetTotalOrdersForFacilityAsync(ManagerDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default)
    {
        var query = context.Orders.AsQueryable();

        // Filter by facilityId
        query = query.Where(o => o.FacilityId == summaryParams.FacilityId);

        // Filter by year
        if (summaryParams.Year.HasValue)
        {
            query = query.Where(o => o.CreatedAt.Year == summaryParams.Year.Value);
        }

        // Exclude pending orders
        query = query.Where(o => o.State != OrderState.Pending);

        return query.CountAsync(cancellationToken);
    }

    public Task<decimal> GetTotalRevenueForFacilityAsync(ManagerDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default)
    {
        var query = context.Orders.AsQueryable();

        // Filter by facilityId
        query = query.Where(o => o.FacilityId == summaryParams.FacilityId);

        // Filter by year
        if (summaryParams.Year.HasValue)
        {
            query = query.Where(o => o.CreatedAt.Year == summaryParams.Year.Value);
        }

        // Exclude pending orders
        query = query.Where(o => o.State != OrderState.Pending);

        // Sum the total revenue
        return query.SumAsync(o => o.Price, cancellationToken);
    }
}
