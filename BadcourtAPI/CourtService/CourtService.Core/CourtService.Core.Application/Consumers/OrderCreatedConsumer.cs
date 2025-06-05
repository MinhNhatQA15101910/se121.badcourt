using AutoMapper;
using CourtService.Core.Domain.Entities;
using CourtService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Consumers;

public class OrderCreatedConsumer(
    ICourtRepository courtRepository,
    IMapper mapper
) : IConsumer<OrderCreatedEvent>
{
    public async Task Consume(ConsumeContext<OrderCreatedEvent> context)
    {
        var court = await courtRepository.GetCourtByIdAsync(context.Message.CourtId)
            ?? throw new CourtNotFoundException(context.Message.CourtId);

        court.OrderPeriods = [
            ..court.OrderPeriods,
            mapper.Map<DateTimePeriod>(context.Message.DateTimePeriodDto)
        ];

        court.UpdatedAt = DateTime.UtcNow;

        await courtRepository.UpdateCourtAsync(court);
        
        Console.WriteLine("Court updated with new order period.");
    }
}
