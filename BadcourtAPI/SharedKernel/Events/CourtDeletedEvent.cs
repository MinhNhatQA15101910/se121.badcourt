namespace SharedKernel.Events;

public record CourtDeletedEvent(string FacilityId, decimal MinPrice, decimal MaxPrice);
