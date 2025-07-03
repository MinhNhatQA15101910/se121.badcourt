using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetTotalManagersForAdminHandler(
    IUserRepository userRepository
) : IQueryHandler<GetTotalManagersForAdminQuery, int>
{
    public async Task<int> Handle(GetTotalManagersForAdminQuery request, CancellationToken cancellationToken)
    {
        return await userRepository.GetTotalManagersForAdminAsync(
            request.SummaryParams, cancellationToken);
    }
}
