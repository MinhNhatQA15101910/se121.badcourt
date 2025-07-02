using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetRevenueByHourForAdmin;

public class GetRevenueByHourForAdminHandler(
    IOrderRepository orderRepository
) : IQueryHandler<GetRevenueByHourForAdminQuery, List<RevenueByHourDto>>
{
    public Task<List<RevenueByHourDto>> Handle(GetRevenueByHourForAdminQuery request, CancellationToken cancellationToken)
    {
        return orderRepository.GetRevenueByHourForAdminAsync(request.RevenueByHourParams, cancellationToken);
    }
}
