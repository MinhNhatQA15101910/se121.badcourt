using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.ApiRepository;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Queries.GetMonthlyRevenueForManager;

public class GetMonthlyRevenueForManagerHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityApiRepository facilityApiRepository,
    IOrderRepository orderRepository
) : IQueryHandler<GetMonthlyRevenueForManagerQuery, List<RevenueByMonthDto>>
{
    public async Task<List<RevenueByMonthDto>> Handle(GetMonthlyRevenueForManagerQuery request, CancellationToken cancellationToken)
    {
        var facilityId = request.Params.FacilityId;
        var facility = await facilityApiRepository.GetFacilityByIdAsync(facilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(facilityId);

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        if (facility.UserId != userId)
        {
            throw new UnauthorizedAccessException("You do not have permission to access this facility's revenue data.");
        }

        return await orderRepository.GetMonthlyRevenueForManagerAsync(
            request.Params,
            cancellationToken
        );
    }
}
