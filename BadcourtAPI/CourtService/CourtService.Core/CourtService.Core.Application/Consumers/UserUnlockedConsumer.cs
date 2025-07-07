using CourtService.Core.Domain.Enums;
using CourtService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Params;

namespace CourtService.Core.Application.Consumers;

public class UserUnlockedConsumer(ICourtRepository courtRepository) : IConsumer<UserUnlockedEvent>
{
    public async Task Consume(ConsumeContext<UserUnlockedEvent> context)
    {
        var courtParams = new CourtParams
        {
            UserId = context.Message.UserId
        };

        var courts = await courtRepository.GetAllCourtAsync(courtParams);
        foreach (var court in courts)
        {
            if (court.UserState == UserState.Locked)
            {
                court.UserState = UserState.Active;
                await courtRepository.UpdateCourtAsync(court);
            }
        }
    }
}
