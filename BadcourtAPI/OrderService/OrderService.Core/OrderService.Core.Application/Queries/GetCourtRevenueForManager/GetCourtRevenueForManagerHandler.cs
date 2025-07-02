using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.ApiRepository;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Queries.GetCourtRevenueForManager;

public class GetCourtRevenueForManagerHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityApiRepository facilityApiRepository,
    IOrderRepository orderRepository
) : IQueryHandler<GetCourtRevenueForManagerQuery, List<CourtRevenueDto>>
{
    public async Task<List<CourtRevenueDto>> Handle(GetCourtRevenueForManagerQuery request, CancellationToken cancellationToken)
    {
        var facilityId = request.CourtRevenueParams.FacilityId;
        var facility = await facilityApiRepository.GetFacilityByIdAsync(facilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(facilityId);

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        if (facility.UserId != userId)
        {
            throw new UnauthorizedAccessException("You do not have permission to access this facility's revenue data.");
        }

        return await orderRepository.GetCourtRevenueForManagerAsync(
            request.CourtRevenueParams,
            cancellationToken
        );
    }
}
