using FacilityService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Consumers;

public class CourtUpdatedConsumer(IFacilityRepository facilityRepository) : IConsumer<CourtUpdatedEvent>
{
    public async Task Consume(ConsumeContext<CourtUpdatedEvent> context)
    {
        Console.WriteLine("CourtUpdatedEvent consumed");
        
        var facility = await facilityRepository.GetFacilityByIdAsync(context.Message.FacilityId, context.CancellationToken)
            ?? throw new FacilityNotFoundException(context.Message.FacilityId);

        facility.MinPrice = context.Message.MinPrice;
        facility.MaxPrice = context.Message.MaxPrice;
        facility.UpdatedAt = DateTime.UtcNow;

        await facilityRepository.UpdateFacilityAsync(facility, context.CancellationToken);
    }
}
