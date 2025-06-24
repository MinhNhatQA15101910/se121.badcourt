using MediatR;

namespace FacilityService.Core.Application.Commands;

public record DeleteFacilityCommand(string FacilityId) : ICommand<bool>;
