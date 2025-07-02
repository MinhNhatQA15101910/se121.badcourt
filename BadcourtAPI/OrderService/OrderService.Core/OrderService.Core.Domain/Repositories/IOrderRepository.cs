using OrderService.Core.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Domain.Repositories;

public interface IOrderRepository
{
    void AddOrder(Order order);
    Task<bool> CompleteAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<Order>> GetAllOrdersAsync(OrderParams orderParams,
        CancellationToken cancellationToken = default);
    Task<Order?> GetByPaymentIntentIdAsync(string paymentIntentId,
        CancellationToken cancellationToken = default);
    Task<List<CourtRevenueDto>> GetCourtRevenueForManagerAsync(ManagerDashboardCourtRevenueParams courtRevenueParams,
        CancellationToken cancellationToken = default);
    Task<List<FacilityRevenueDto>> GetFacilityRevenueForAdminAsync(
        AdminDashboardFacilityRevenueParams facilityRevenueParams, CancellationToken cancellationToken = default);
    Task<List<RevenueByMonthDto>> GetMonthlyRevenueForManagerAsync(ManagerDashboardMonthlyRevenueParams @params, 
        CancellationToken cancellationToken = default);
    Task<Order?> GetOrderByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<PagedList<OrderDto>> GetOrderDetailsAsync(string? userId, OrderParams orderParams,
        CancellationToken cancellationToken = default);
    Task<PagedList<OrderDto>> GetOrdersAsync(OrderParams orderParams,
        CancellationToken cancellationToken = default, Guid? userId = null);
    Task<PagedList<OrderDto>> GetOrdersForManagerAsync(
        ManagerDashboardOrderParams orderParams, Guid userId, CancellationToken cancellationToken = default);
    Task<List<ProvinceRevenueDto>> GetProvinceRevenueForAdminAsync(
        AdminDashboardProvinceRevenueParams provinceRevenueParams, CancellationToken cancellationToken = default);
    Task<List<RevenueStatDto>> GetRevenueStatsForAdminAsync(
        AdminDashboardRevenueStatParams revenueStatParams, CancellationToken cancellationToken = default);
    Task<int> GetTotalCustomersForFacilityAsync(ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
    Task<int> GetTotalOrdersForAdminAsync(
        AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default);
    Task<int> GetTotalOrdersForFacilityAsync(ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
    Task<decimal> GetTotalRevenueForAdminAsync(
        AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken);
    Task<decimal> GetTotalRevenueForFacilityAsync(ManagerDashboardSummaryParams summaryParams,
        CancellationToken cancellationToken = default);
}
