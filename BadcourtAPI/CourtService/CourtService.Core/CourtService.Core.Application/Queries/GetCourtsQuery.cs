using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace CourtService.Core.Application.Queries;

public record GetCourtsQuery(CourtParams CourtParams) : IQuery<PagedList<CourtDto>>;
