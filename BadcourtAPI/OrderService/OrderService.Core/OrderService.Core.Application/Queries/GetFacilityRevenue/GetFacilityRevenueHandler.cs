using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetFacilityRevenue;

public class GetFacilityRevenueHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderRepository orderRepository
) : IQueryHandler<GetFacilityRevenueQuery, List<FacilityRevenueDto>>
{
    public async Task<List<FacilityRevenueDto>> Handle(GetFacilityRevenueQuery request, CancellationToken cancellationToken)
    {
        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (roles.Contains("Admin"))
        {
            return await orderRepository.GetFacilityRevenueAsync(
                null, request.ManagerDashboardFacilityRevenueParams, cancellationToken);
        }

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        return await orderRepository.GetFacilityRevenueAsync(
            userId.ToString(), request.ManagerDashboardFacilityRevenueParams, cancellationToken);
    }
}
