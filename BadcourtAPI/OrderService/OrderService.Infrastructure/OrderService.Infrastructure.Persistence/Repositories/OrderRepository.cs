using OrderService.Core.Domain.Entities;
using OrderService.Core.Domain.Repositories;

namespace OrderService.Infrastructure.Persistence.Repositories;

public class OrderRepository(DataContext context) : IOrderRepository
{
    public void AddOrder(Order order)
    {
        context.Orders.Add(order);
    }

    public async Task<bool> CompleteAsync(CancellationToken cancellationToken = default)
    {
        return await context.SaveChangesAsync(cancellationToken) > 0;
    }
}
