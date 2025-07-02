
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.ApiRepository;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Queries.GetTotalRevenueForManager;

public class GetTotalRevenueForManagerHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityApiRepository facilityApiRepository,
    IOrderRepository orderRepository
) : IQueryHandler<GetTotalRevenueForManagerQuery, decimal>
{
    public async Task<decimal> Handle(GetTotalRevenueForManagerQuery request, CancellationToken cancellationToken)
    {
        var facilityId = request.SummaryParams.FacilityId;
        var facility = await facilityApiRepository.GetFacilityByIdAsync(facilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(facilityId);

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        if (facility.UserId != userId)
        {
            throw new UnauthorizedAccessException("You do not have permission to access this facility's revenue data.");
        }

        return await orderRepository.GetTotalRevenueForFacilityAsync(
            request.SummaryParams, cancellationToken);
    }
}
