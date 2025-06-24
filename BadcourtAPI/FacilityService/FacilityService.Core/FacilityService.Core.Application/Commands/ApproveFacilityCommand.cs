namespace FacilityService.Core.Application.Commands;

public record ApproveFacilityCommand(string FacilityId) : ICommand<bool>;
