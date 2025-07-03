using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetUserStatsForAdminHandler(
    IUserRepository userRepository
) : IQueryHandler<GetUserStatsForAdminQuery, List<UserStatDto>>
{
    public Task<List<UserStatDto>> Handle(GetUserStatsForAdminQuery request, CancellationToken cancellationToken)
    {
        return userRepository.GetUserStatsForAdminAsync(request.UserStatParams, cancellationToken);
    }
}
