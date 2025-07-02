using OrderService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetProvinceRevenueForAdmin;

public class GetProvinceRevenueForAdminHandler(
    IOrderRepository orderRepository
) : IQueryHandler<GetProvinceRevenueForAdminQuery, PagedList<ProvinceRevenueDto>>
{
    public Task<PagedList<ProvinceRevenueDto>> Handle(GetProvinceRevenueForAdminQuery request, CancellationToken cancellationToken)
    {
        return orderRepository.GetProvinceRevenueForAdminAsync(request.ProvinceRevenueParams, cancellationToken);
    }
}
