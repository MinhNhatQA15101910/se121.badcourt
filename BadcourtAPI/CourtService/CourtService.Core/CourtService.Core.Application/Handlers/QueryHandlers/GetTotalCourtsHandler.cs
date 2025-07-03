using CourtService.Core.Application.Extensions;
using CourtService.Core.Application.Interfaces.ServiceClients;
using CourtService.Core.Application.Queries;
using CourtService.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Handlers.QueryHandlers;

public class GetTotalCourtsHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityServiceClient facilityServiceClient,
    ICourtRepository courtRepository
) : IQueryHandler<GetTotalCourtsForManagerQuery, int>
{
    public async Task<int> Handle(GetTotalCourtsForManagerQuery request, CancellationToken cancellationToken)
    {
        var facilityId = request.Params.FacilityId;
        var facility = await facilityServiceClient.GetFacilityByIdAsync(facilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(facilityId);

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        if (facility.UserId != userId)
        {
            throw new UnauthorizedAccessException("You do not have permission to access this facility.");
        }

        return await courtRepository.GetTotalCourtsForFacilityAsync(request.Params, cancellationToken);
    }
}
