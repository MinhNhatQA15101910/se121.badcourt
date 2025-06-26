using FacilityService.Core.Application.Extensions;
using FacilityService.Core.Application.Queries;
using FacilityService.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;

namespace FacilityService.Core.Application.Handlers.QueryHandlers;

public class GetTotalFacilitiesHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityRepository facilityRepository
) : IQueryHandler<GetTotalFacilitiesQuery, int>
{
    public Task<int> Handle(GetTotalFacilitiesQuery request, CancellationToken cancellationToken)
    {
        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (roles.Contains("Admin"))
        {
            return facilityRepository.GetTotalFacilitiesAsync(null, cancellationToken);
        }

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        return facilityRepository.GetTotalFacilitiesAsync(userId.ToString(), cancellationToken);
    }
}
