using AutoMapper;
using BadCourtAPI.Dtos.Users;
using BadCourtAPI.Entities;
using BadCourtAPI.Exceptions;
using BadCourtAPI.Features.Commands.Auth;
using BadCourtAPI.Interfaces.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace BadCourtAPI.Features.Handlers.CommandHandlers.Auth;

public class LoginUserCommandHandler(
    UserManager<User> userManager,
    IMapper mapper,
    ITokenService tokenService
) : ICommandHandler<LoginUserCommand, UserDto>
{
    public async Task<UserDto> Handle(LoginUserCommand request, CancellationToken cancellationToken)
    {
        var existingUser = await userManager.Users
            .Include(x => x.Photos)
            .Include(x => x.UserRoles).ThenInclude(x => x.Role)
            .SingleOrDefaultAsync(x => x.NormalizedEmail == request.LoginDto.Email.ToUpper(), cancellationToken)
            ?? throw new UnauthorizedException("User with this email does not exist.");
        
        var result = await userManager.CheckPasswordAsync(existingUser, request.LoginDto.Password);
        if (!result)
        {
            throw new UnauthorizedException("Invalid password.");
        }

        var userDto = mapper.Map<UserDto>(existingUser);
        userDto.Token = await tokenService.CreateTokenAsync(existingUser);

        return userDto;
    }
}
