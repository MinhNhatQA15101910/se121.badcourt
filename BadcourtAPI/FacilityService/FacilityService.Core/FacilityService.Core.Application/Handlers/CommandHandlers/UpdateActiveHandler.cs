using AutoMapper;
using FacilityService.Core.Application.Commands;
using FacilityService.Core.Application.Notifications;
using FacilityService.Core.Domain.Entities;
using FacilityService.Core.Domain.Repositories;
using MediatR;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public class UpdateActiveHandler(
    IFacilityRepository facilityRepository,
    IMapper mapper,
    IMediator mediator
) : ICommandHandler<UpdateActiveCommand, bool>
{
    public async Task<bool> Handle(UpdateActiveCommand request, CancellationToken cancellationToken)
    {
        var facility = await facilityRepository.GetFacilityByIdAsync(request.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(request.FacilityId);

        if (facility.UserId != request.CurrentUserId)
            throw new ForbiddenAccessException("You do not have permission to update this facility.");

        facility.ActiveAt = mapper.Map<Active>(request.ActiveDto);

        await facilityRepository.UpdateFacilityAsync(facility, cancellationToken);

        // Publish notification after updating the facility
        await mediator.Publish(new FacilityUpdatedNotification(facility), cancellationToken);

        return true;
    }
}
