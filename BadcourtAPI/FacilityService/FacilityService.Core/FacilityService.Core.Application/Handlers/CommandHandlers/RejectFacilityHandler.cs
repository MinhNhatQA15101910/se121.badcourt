using FacilityService.Core.Application.Commands;
using FacilityService.Core.Domain.Enums;
using FacilityService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public class RejectFacilityHandler(
    IFacilityRepository facilityRepository,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<RejectFacilityCommand, bool>
{
    public async Task<bool> Handle(RejectFacilityCommand request, CancellationToken cancellationToken)
    {
        var facility = await facilityRepository.GetFacilityByIdAsync(request.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(request.FacilityId);

        if (facility.UserState == UserState.Locked)
        {
            throw new FacilityLockedException(facility.Id);
        }

        facility.State = FacilityState.Rejected;
        facility.UpdatedAt = DateTime.UtcNow;

        await facilityRepository.UpdateFacilityAsync(facility, cancellationToken);

        await publishEndpoint.Publish(new FacilityRejectedEvent
        (
            facility.UserId.ToString(),
            facility.Id,
            facility.FacilityName
        ), cancellationToken);

        return true;
    }
}
