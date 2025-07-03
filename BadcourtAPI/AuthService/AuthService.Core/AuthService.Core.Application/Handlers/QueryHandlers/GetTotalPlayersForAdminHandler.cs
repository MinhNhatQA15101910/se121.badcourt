using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetTotalPlayersForAdminHandler(
    IUserRepository userRepository
) : IQueryHandler<GetTotalPlayersForAdminQuery, int>
{
    public async Task<int> Handle(GetTotalPlayersForAdminQuery request, CancellationToken cancellationToken)
    {
        return await userRepository.GetTotalPlayersForAdminAsync(
            request.SummaryParams,
            cancellationToken
        );
    }
}
