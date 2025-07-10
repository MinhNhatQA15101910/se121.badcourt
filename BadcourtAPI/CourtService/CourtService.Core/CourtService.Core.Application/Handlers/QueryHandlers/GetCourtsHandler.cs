using CourtService.Core.Application.Queries;
using CourtService.Core.Domain.Repositories;
using SharedKernel;
using SharedKernel.DTOs;

namespace CourtService.Core.Application.Handlers.QueryHandlers;

public class GetCourtsHandler(
    ICourtRepository courtRepository
) : IQueryHandler<GetCourtsQuery, PagedList<CourtDto>>
{
    public async Task<PagedList<CourtDto>> Handle(GetCourtsQuery request, CancellationToken cancellationToken)
    {
        return await courtRepository.GetCourtsAsync(request.CourtParams, cancellationToken);
    }
}
