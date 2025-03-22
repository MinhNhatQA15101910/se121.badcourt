using AuthService.Core.Application.Commands;
using AuthService.Core.Application.Interfaces;
using AuthService.Core.Domain.Entities;
using AuthService.Core.Domain.Exceptions;
using AutoMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class LoginHandler(
    UserManager<User> userManager,
    IMapper mapper,
    ITokenService tokenService
) : ICommandHandler<LoginCommand, UserDto>
{
    public async Task<UserDto> Handle(LoginCommand request, CancellationToken cancellationToken)
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
