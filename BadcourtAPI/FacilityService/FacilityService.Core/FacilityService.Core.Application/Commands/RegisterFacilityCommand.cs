using FacilityService.Core.Application.DTOs;
using SharedKernel.DTOs;

namespace FacilityService.Core.Application.Commands;

public record RegisterFacilityCommand(RegisterFacilityDto RegisterFacilityDto) : ICommand<FacilityDto>;
