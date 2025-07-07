using FacilityService.Core.Domain.Enums;
using FacilityService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Params;

namespace FacilityService.Core.Application.Consumers;

public class UserLockedConsumer(
    IFacilityRepository facilityRepository
) : IConsumer<UserLockedEvent>
{
    public async Task Consume(ConsumeContext<UserLockedEvent> context)
    {
        var facilityParams = new FacilityParams
        {
            UserId = context.Message.UserId
        };
        var facilities = await facilityRepository.GetAllFacilitiesAsync(facilityParams);

        foreach (var facility in facilities)
        {
            if (facility.UserState == UserState.Active)
            {
                facility.UserState = UserState.Locked;
                await facilityRepository.UpdateFacilityAsync(facility);
            }
        }
    }
}
