using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetFacilityRevenueForAdmin;

public class GetFacilityRevenueForAdminHandler(
    IOrderRepository orderRepository
) : IQueryHandler<GetFacilityRevenueForAdminQuery, List<FacilityRevenueDto>>
{
    public Task<List<FacilityRevenueDto>> Handle(GetFacilityRevenueForAdminQuery request, CancellationToken cancellationToken)
    {
        return orderRepository.GetFacilityRevenueForAdminAsync(request.FacilityRevenueParams, cancellationToken);
    }
}
