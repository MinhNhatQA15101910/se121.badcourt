using OrderService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetFacilityRevenueForAdmin;

public class GetFacilityRevenueForAdminHandler(
    IOrderRepository orderRepository
) : IQueryHandler<GetFacilityRevenueForAdminQuery, PagedList<FacilityRevenueDto>>
{
    public Task<PagedList<FacilityRevenueDto>> Handle(GetFacilityRevenueForAdminQuery request, CancellationToken cancellationToken)
    {
        return orderRepository.GetFacilityRevenueForAdminAsync(request.FacilityRevenueParams, cancellationToken);
    }
}
