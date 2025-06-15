using AutoMapper;
using MassTransit;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.SignalR;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace RealtimeService.Presentation.Consumers;

public class CourtInactiveUpdatedConsumer(
    IHubContext<CourtHub> courtHub,
    ICourtRepository courtRepository,
    IMapper mapper
) : IConsumer<CourtInactiveUpdatedEvent>
{
    public async Task Consume(ConsumeContext<CourtInactiveUpdatedEvent> context)
    {
        await UpdateCourtInactive(context);

        var courtId = context.Message.CourtId;
        var dateTimePeriodDto = context.Message.DateTimePeriodDto;

        await courtHub.Clients.Group(courtId)
            .SendAsync("CourtInactiveUpdated", dateTimePeriodDto);
    }

    private async Task UpdateCourtInactive(ConsumeContext<CourtInactiveUpdatedEvent> context)
    {
        var court = await courtRepository.GetCourtByIdAsync(context.Message.CourtId)
            ?? throw new CourtNotFoundException(context.Message.CourtId);

        court.InactivePeriods = [
            ..court.InactivePeriods,
            mapper.Map<DateTimePeriod>(context.Message.DateTimePeriodDto)
        ];
        court.UpdatedAt = DateTime.UtcNow;

        await courtRepository.UpdateCourtAsync(court);
    }
}
