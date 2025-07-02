using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetTotalNewManagersForAdminHandler(
    IUserRepository userRepository
) : IQueryHandler<GetTotalNewManagersForAdminQuery, int>
{
    public async Task<int> Handle(GetTotalNewManagersForAdminQuery request, CancellationToken cancellationToken)
    {
        return await userRepository.GetTotalNewManagersForAdminAsync(cancellationToken);
    }
}
