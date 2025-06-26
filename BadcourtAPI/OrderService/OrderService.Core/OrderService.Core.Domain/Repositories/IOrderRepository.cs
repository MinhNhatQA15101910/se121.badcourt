using OrderService.Core.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Domain.Repositories;

public interface IOrderRepository
{
    void AddOrder(Order order);
    Task<bool> CompleteAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<Order>> GetAllOrdersAsync(OrderParams orderParams, CancellationToken cancellationToken = default);
    Task<Order?> GetByPaymentIntentIdAsync(string paymentIntentId, CancellationToken cancellationToken = default);
    Task<List<FacilityRevenueDto>> GetFacilityRevenueAsync(string? userId,
        ManagerDashboardFacilityRevenueParams managerDashboardFacilityRevenueParams, CancellationToken cancellationToken = default);
    Task<List<RevenueByMonthDto>> GetMonthlyRevenueAsync(string? userId,
        ManagerDashboardMonthlyRevenueParams managerDashboardMonthlyRevenueParams, CancellationToken cancellationToken = default);
    Task<Order?> GetOrderByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<PagedList<OrderDto>> GetOrdersAsync(OrderParams orderParams, CancellationToken cancellationToken = default, Guid? userId = null);
    Task<int> GetTotalCustomersAsync(string? userId, int? year, CancellationToken cancellationToken);
    Task<int> GetTotalOrdersAsync(string? userId, int? year, CancellationToken cancellationToken = default);
    Task<decimal> GetTotalRevenueAsync(string? userId, int? year, CancellationToken cancellationToken = default);
}
