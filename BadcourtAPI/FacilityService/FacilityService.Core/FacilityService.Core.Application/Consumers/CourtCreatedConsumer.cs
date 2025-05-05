using FacilityService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Consumers;

public class CourtCreatedConsumer(
    IFacilityRepository facilityRepository
) : IConsumer<CourtCreatedEvent>
{
    public async Task Consume(ConsumeContext<CourtCreatedEvent> context)
    {
        Console.WriteLine("CourtCreatedEvent consumed");

        var facility = await facilityRepository.GetFacilityByIdAsync(context.Message.FacilityId, context.CancellationToken)
            ?? throw new FacilityNotFoundException(context.Message.FacilityId);

        facility.CourtsAmount++;

        if (facility.MinPrice > context.Message.PricePerHour)
        {
            facility.MinPrice = context.Message.PricePerHour;
        }
        if (facility.MaxPrice < context.Message.PricePerHour)
        {
            facility.MaxPrice = context.Message.PricePerHour;
        }

        facility.UpdatedAt = DateTime.UtcNow;

        await facilityRepository.UpdateFacilityAsync(facility, context.CancellationToken);
    }
}
