using FacilityService.Core.Domain.Enums;
using FacilityService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Params;

namespace FacilityService.Core.Application.Consumers;

public class UserUnlockedConsumer(
    IFacilityRepository facilityRepository
) : IConsumer<UserUnlockedEvent>
{
    public async Task Consume(ConsumeContext<UserUnlockedEvent> context)
    {
        var facilityParams = new FacilityParams
        {
            UserId = context.Message.UserId
        };
        var facilities = await facilityRepository.GetAllFacilitiesAsync(facilityParams);

        foreach (var facility in facilities)
        {
            if (facility.UserState == UserState.Locked)
            {
                facility.UserState = UserState.Active;
                await facilityRepository.UpdateFacilityAsync(facility);
            }
        }
    }
}
