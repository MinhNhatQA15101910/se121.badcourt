using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace FacilityService.Core.Application.Queries;

public record GetFacilitiesQuery(FacilityParams FacilityParams) : IQuery<PagedList<FacilityDto>>;
