using FacilityService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Consumers;

public class FacilityRatedConsumer(IFacilityRepository facilityRepository) : IConsumer<FacilityRatedEvent>
{
    public async Task Consume(ConsumeContext<FacilityRatedEvent> context)
    {
        var facility = await facilityRepository.GetFacilityByIdAsync(context.Message.FacilityId)
            ?? throw new FacilityNotFoundException(context.Message.FacilityId);

        facility.RatingAvg = (facility.RatingAvg * facility.TotalRatings + context.Message.Stars) / (facility.TotalRatings + 1);
        facility.TotalRatings++;

        await facilityRepository.UpdateFacilityAsync(facility);
    }
}
