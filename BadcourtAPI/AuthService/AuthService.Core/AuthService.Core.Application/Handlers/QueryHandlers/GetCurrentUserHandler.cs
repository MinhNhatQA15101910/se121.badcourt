using AuthService.Core.Application.Extensions;
using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;
using AutoMapper;
using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetCurrentUserHandler(
    IUserRepository userRepository,
    IHttpContextAccessor httpContextAccessor,
    IMapper mapper
) : IQueryHandler<GetCurrentUserQuery, UserDto>
{
    public async Task<UserDto> Handle(GetCurrentUserQuery request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        var user = await userRepository.GetUserByIdAsync(userId, cancellationToken);

        var userDto = mapper.Map<UserDto>(user);
        userDto.Token = httpContextAccessor.HttpContext.GetBearerToken();

        return mapper.Map<UserDto>(user);
    }
}
