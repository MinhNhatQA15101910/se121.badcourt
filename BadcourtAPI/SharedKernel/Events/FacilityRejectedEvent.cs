namespace SharedKernel.Events;

public record FacilityRejectedEvent(string ManagerId, string FacilityId, string FacilityName);
