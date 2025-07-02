using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetRevenueStatsForAdmin;

public class GetRevenueStatsForAdminHandler(
    IOrderRepository orderRepository
) : IQueryHandler<GetRevenueStatsForAdminQuery, List<RevenueStatDto>>
{
    public Task<List<RevenueStatDto>> Handle(GetRevenueStatsForAdminQuery request, CancellationToken cancellationToken)
    {
        return orderRepository.GetRevenueStatsForAdminAsync(request.RevenueStatParams, cancellationToken);
    }
}
