using FacilityService.Core.Application.Commands;
using FacilityService.Core.Domain.Enums;
using FacilityService.Core.Domain.Repositories;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public class ApproveFacilityHandler(
    IFacilityRepository facilityRepository
) : ICommandHandler<ApproveFacilityCommand, bool>
{
    public async Task<bool> Handle(ApproveFacilityCommand request, CancellationToken cancellationToken)
    {
        var facility = await facilityRepository.GetFacilityByIdAsync(request.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(request.FacilityId);

        facility.State = FacilityState.Approved;
        facility.UpdatedAt = DateTime.UtcNow;

        await facilityRepository.UpdateFacilityAsync(facility, cancellationToken);

        return true;
    }
}
