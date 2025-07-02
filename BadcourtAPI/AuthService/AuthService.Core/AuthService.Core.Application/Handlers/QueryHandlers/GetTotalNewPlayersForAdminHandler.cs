using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetTotalNewPlayersForAdminHandler(
    IUserRepository userRepository
) : IQueryHandler<GetTotalNewPlayersForAdminQuery, int>
{
    public async Task<int> Handle(GetTotalNewPlayersForAdminQuery request, CancellationToken cancellationToken)
    {
        return await userRepository.GetTotalNewPlayersForAdminAsync(cancellationToken);
    }
}
