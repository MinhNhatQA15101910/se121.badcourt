
using Microsoft.AspNetCore.Http;
using OrderService.Core.Application.ApiRepository;
using OrderService.Core.Application.Extensions;
using OrderService.Core.Domain.Repositories;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Queries.GetTotalOrdersForManager;

public class GetTotalOrdersForManagerHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityApiRepository facilityApiRepository,
    IOrderRepository orderRepository
) : IQueryHandler<GetTotalOrdersForManagerQuery, int>
{
    public async Task<int> Handle(GetTotalOrdersForManagerQuery request, CancellationToken cancellationToken)
    {
        var facilityId = request.SummaryParams.FacilityId;
        var facility = await facilityApiRepository.GetFacilityByIdAsync(facilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(facilityId);

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        if (facility.UserId != userId)
        {
            throw new UnauthorizedAccessException("You do not have permission to access this facility's order data.");
        }

        return await orderRepository.GetTotalOrdersForFacilityAsync(
            request.SummaryParams, cancellationToken);
    }
}
