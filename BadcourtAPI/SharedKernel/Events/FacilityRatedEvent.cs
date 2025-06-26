namespace SharedKernel.Events;

public record FacilityRatedEvent(string FacilityOwnerId, string FacilityId, int Stars);
