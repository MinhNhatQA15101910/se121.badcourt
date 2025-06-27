using FacilityService.Core.Application.DTOs;

namespace FacilityService.Core.Application.Commands;

public record UpdateActiveCommand(
    string FacilityId,
    UpdateActiveDto UpdateActiveDto
) : ICommand<bool>;
