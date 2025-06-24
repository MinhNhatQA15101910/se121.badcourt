using CourtService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Consumers;

public class OrderCancelledConsumer(
    ICourtRepository courtRepository
) : IConsumer<OrderCancelledEvent>
{
    public async Task Consume(ConsumeContext<OrderCancelledEvent> context)
    {
        var court = await courtRepository.GetCourtByIdAsync(context.Message.CourtId)
            ?? throw new CourtNotFoundException(context.Message.CourtId);

        court.OrderPeriods = [.. court.OrderPeriods
            .Where(op => op.HourFrom != context.Message.DateTimePeriodDto.HourFrom ||
                op.HourTo != context.Message.DateTimePeriodDto.HourTo)];

        court.UpdatedAt = DateTime.UtcNow;

        await courtRepository.UpdateCourtAsync(court);

        Console.WriteLine("Court updated with cancelled order period.");
    }
}
