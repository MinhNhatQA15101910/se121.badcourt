using FacilityService.Core.Application.Commands;
using FacilityService.Core.Domain.Enums;
using FacilityService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public class ApproveFacilityHandler(
    IFacilityRepository facilityRepository,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<ApproveFacilityCommand, bool>
{
    public async Task<bool> Handle(ApproveFacilityCommand request, CancellationToken cancellationToken)
    {
        var facility = await facilityRepository.GetFacilityByIdAsync(request.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(request.FacilityId);

        if (facility.UserState == UserState.Locked)
        {
            throw new FacilityLockedException(facility.Id);
        }

        facility.State = FacilityState.Approved;
        facility.UpdatedAt = DateTime.UtcNow;

        await facilityRepository.UpdateFacilityAsync(facility, cancellationToken);

        await publishEndpoint.Publish(new FacilityApprovedEvent
        (
            facility.UserId.ToString(),
            facility.Id,
            facility.FacilityName
        ), cancellationToken);

        return true;
    }
}
