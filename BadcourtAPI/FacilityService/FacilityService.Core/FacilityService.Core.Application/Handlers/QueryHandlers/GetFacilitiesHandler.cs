using FacilityService.Core.Application.Queries;
using FacilityService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;

namespace FacilityService.Core.Application.Handlers.QueryHandlers;

public class GetFacilitiesHandler(
    IFacilityRepository facilityRepository
) : IQueryHandler<GetFacilitiesQuery, PagedList<FacilityDto>>
{
    public async Task<PagedList<FacilityDto>> Handle(GetFacilitiesQuery request, CancellationToken cancellationToken)
    {
        return await facilityRepository.GetFacilitiesAsync(request.FacilityParams, cancellationToken);
    }
}
