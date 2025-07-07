using CourtService.Core.Domain.Enums;
using CourtService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Params;

namespace CourtService.Core.Application.Consumers;

public class UserLockedConsumer(
    ICourtRepository courtRepository
) : IConsumer<UserLockedEvent>
{
    public async Task Consume(ConsumeContext<UserLockedEvent> context)
    {
        var courtParams = new CourtParams
        {
            UserId = context.Message.UserId
        };

        var courts = await courtRepository.GetAllCourtAsync(courtParams);
        foreach (var court in courts)
        {
            if (court.UserState == UserState.Active)
            {
                court.UserState = UserState.Locked;
                await courtRepository.UpdateCourtAsync(court);
            }
        }
    }
}
