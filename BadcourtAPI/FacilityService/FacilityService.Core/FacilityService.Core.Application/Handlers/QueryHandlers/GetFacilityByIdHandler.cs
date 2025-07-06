using AutoMapper;
using FacilityService.Core.Application.Queries;
using FacilityService.Core.Domain.Enums;
using FacilityService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.QueryHandlers;

public class GetFacilityByIdHandler(
    IFacilityRepository facilityRepository,
    IMapper mapper
) : IQueryHandler<GetFacilityByIdQuery, FacilityDto>
{
    public async Task<FacilityDto> Handle(GetFacilityByIdQuery request, CancellationToken cancellationToken)
    {
        var facility = await facilityRepository.GetFacilityByIdAsync(request.Id, cancellationToken)
            ?? throw new FacilityNotFoundException(request.Id);

        if (facility.UserState == UserState.Locked) throw new FacilityLockedException(request.Id);

        return mapper.Map<FacilityDto>(facility);
    }
}
