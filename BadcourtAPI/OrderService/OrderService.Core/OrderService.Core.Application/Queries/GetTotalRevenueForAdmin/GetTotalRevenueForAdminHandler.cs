
using OrderService.Core.Domain.Repositories;

namespace OrderService.Core.Application.Queries.GetTotalRevenueForAdmin;

public class GetTotalRevenueForAdminHandler(
    IOrderRepository orderRepository
) : IQueryHandler<GetTotalRevenueForAdminQuery, decimal>
{
    public async Task<decimal> Handle(GetTotalRevenueForAdminQuery request, CancellationToken cancellationToken)
    {
        return await orderRepository.GetTotalRevenueForAdminAsync(
            request.SummaryParams,
            cancellationToken
        );
    }
}
