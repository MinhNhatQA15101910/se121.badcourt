using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;
using MediatR;
using SharedKernel;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetUsersHandler(IUserRepository userRepository) : IRequestHandler<GetUsersQuery, PagedList<UserDto>>
{
    public async Task<PagedList<UserDto>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
    {
        return await userRepository.GetUsersAsync(request.UserParams);
    }
}
