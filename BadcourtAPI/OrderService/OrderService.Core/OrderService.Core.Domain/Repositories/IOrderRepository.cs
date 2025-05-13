using OrderService.Core.Domain.Entities;
using SharedKernel.DTOs;

namespace OrderService.Core.Domain.Repositories;

public interface IOrderRepository
{
    void AddOrder(Order order);
    Task<bool> CompleteAsync(CancellationToken cancellationToken = default);
    Task<Order?> GetOrderByIdAsync(Guid id, CancellationToken cancellationToken = default);
}
