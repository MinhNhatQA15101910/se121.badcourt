using SharedKernel.DTOs;

namespace FacilityService.Core.Application.Commands;

public record UpdateActiveCommand(string FacilityId, Guid CurrentUserId, ActiveDto ActiveDto) : ICommand<bool>;
