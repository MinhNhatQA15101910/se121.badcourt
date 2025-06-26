using FacilityService.Core.Application.DTOs;

namespace FacilityService.Core.Application.Commands;

public record UpdateFacilityCommand(string FacilityId, UpdateFacilityDto UpdateFacilityDto) : ICommand<bool>;
