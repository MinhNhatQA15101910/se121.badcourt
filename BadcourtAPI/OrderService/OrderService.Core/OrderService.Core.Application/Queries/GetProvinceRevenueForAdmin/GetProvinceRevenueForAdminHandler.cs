using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetProvinceRevenueForAdmin;

public class GetProvinceRevenueForAdminHandler(
    IOrderRepository orderRepository
) : IQueryHandler<GetProvinceRevenueForAdminQuery, List<ProvinceRevenueDto>>
{
    public Task<List<ProvinceRevenueDto>> Handle(GetProvinceRevenueForAdminQuery request, CancellationToken cancellationToken)
    {
        return orderRepository.GetProvinceRevenueForAdminAsync(request.ProvinceRevenueParams, cancellationToken);
    }
}
