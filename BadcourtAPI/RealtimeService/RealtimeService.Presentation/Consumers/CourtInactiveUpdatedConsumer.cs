using MassTransit;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Presentation.SignalR;
using SharedKernel.Events;

namespace RealtimeService.Presentation.Consumers;

public class CourtInactiveUpdatedConsumer(IHubContext<CourtHub> courtHub) : IConsumer<CourtInactiveUpdatedEvent>
{
    public async Task Consume(ConsumeContext<CourtInactiveUpdatedEvent> context)
    {
        var courtId = context.Message.CourtId;
        var dateTimePeriodDto = context.Message.DateTimePeriodDto;

        await courtHub.Clients.Group(courtId)
            .SendAsync("CourtInactiveUpdated", dateTimePeriodDto);
    }
}
