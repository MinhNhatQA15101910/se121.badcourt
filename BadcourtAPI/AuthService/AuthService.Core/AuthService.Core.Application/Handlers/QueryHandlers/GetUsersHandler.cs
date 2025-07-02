using AuthService.Core.Application.Extensions;
using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;
using MediatR;
using Microsoft.AspNetCore.Http;
using SharedKernel;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetUsersHandler(
    IHttpContextAccessor httpContextAccessor,
    IUserRepository userRepository
) : IRequestHandler<GetUsersQuery, PagedList<UserDto>>
{
    public async Task<PagedList<UserDto>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        return await userRepository.GetUsersAsync(userId, request.UserParams, cancellationToken);
    }
}
