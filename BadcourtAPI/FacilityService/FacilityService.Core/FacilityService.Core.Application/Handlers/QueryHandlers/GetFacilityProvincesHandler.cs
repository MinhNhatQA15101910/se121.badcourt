using FacilityService.Core.Application.Queries;
using FacilityService.Core.Domain.Repositories;

namespace FacilityService.Core.Application.Handlers.QueryHandlers;

public class GetFacilityProvincesHandler(
    IFacilityRepository facilityRepository
) : IQueryHandler<GetFacilityProvincesQuery, List<string>>
{
    public async Task<List<string>> Handle(GetFacilityProvincesQuery request, CancellationToken cancellationToken)
    {
        return await facilityRepository.GetFacilityProvincesAsync(cancellationToken);
    }
}
