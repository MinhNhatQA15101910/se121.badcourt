using SharedKernel.DTOs;

namespace FacilityService.Core.Application.Queries;

public record GetFacilityByIdQuery(string Id) : IQuery<FacilityDto>;
