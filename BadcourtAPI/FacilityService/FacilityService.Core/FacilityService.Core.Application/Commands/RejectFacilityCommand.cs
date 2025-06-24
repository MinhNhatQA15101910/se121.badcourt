namespace FacilityService.Core.Application.Commands;

public record RejectFacilityCommand(string FacilityId) : ICommand<bool>;
