namespace SharedKernel.Events;

public record FacilityApprovedEvent(string ManagerId, string FacilityId, string FacilityName);
