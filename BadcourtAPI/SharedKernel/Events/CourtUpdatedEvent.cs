namespace SharedKernel.Events;

public record CourtUpdatedEvent(string FacilityId, decimal MinPrice, decimal MaxPrice);
