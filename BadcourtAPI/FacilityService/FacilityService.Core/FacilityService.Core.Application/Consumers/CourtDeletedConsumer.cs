using FacilityService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Consumers;

public class CourtDeletedConsumer(IFacilityRepository facilityRepository) : IConsumer<CourtDeletedEvent>
{
    public async Task Consume(ConsumeContext<CourtDeletedEvent> context)
    {
        Console.WriteLine("CourtDeletedEvent consumed");

        var facility = await facilityRepository.GetFacilityByIdAsync(context.Message.FacilityId, context.CancellationToken)
            ?? throw new FacilityNotFoundException(context.Message.FacilityId);

        facility.CourtsAmount--;
        facility.MinPrice = context.Message.MinPrice;
        facility.MaxPrice = context.Message.MaxPrice;

        facility.UpdatedAt = DateTime.UtcNow;

        await facilityRepository.UpdateFacilityAsync(facility, context.CancellationToken);
    }
}
