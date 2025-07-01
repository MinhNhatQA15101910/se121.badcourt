using CourtService.Core.Application.Extensions;
using CourtService.Core.Application.Queries;
using CourtService.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;

namespace CourtService.Core.Application.Handlers.QueryHandlers;

public class GetTotalCourtsHandler(
    IHttpContextAccessor httpContextAccessor,
    ICourtRepository courtRepository
) : IQueryHandler<GetTotalCourtsQuery, int>
{
    public async Task<int> Handle(GetTotalCourtsQuery request, CancellationToken cancellationToken)
    {
        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (roles.Contains("Admin"))
        {
            return await courtRepository.GetTotalCourtsAsync(null, request.Params, cancellationToken);
        }

        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        return await courtRepository.GetTotalCourtsAsync(userId.ToString(), request.Params, cancellationToken);
    }
}
