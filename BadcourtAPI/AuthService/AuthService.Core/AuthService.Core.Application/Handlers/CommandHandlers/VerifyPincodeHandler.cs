using AuthService.Core.Application.Commands;
using AuthService.Core.Application.Interfaces;
using AuthService.Core.Application.Services;
using AuthService.Core.Domain.Entities;
using AuthService.Core.Domain.Enums;
using AutoMapper;
using Microsoft.AspNetCore.Identity;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class VerifyPincodeHandler(
    PincodeStore pincodeStore,
    IMapper mapper,
    UserManager<User> userManager,
    ITokenService tokenService
) : ICommandHandler<VerifyPincodeCommand, object>
{
    public async Task<object> Handle(VerifyPincodeCommand request, CancellationToken cancellationToken)
    {
        var pincode = pincodeStore.GetPincode(request.VerifyPincodeDto.Email!);
        if (pincode != request.VerifyPincodeDto.Pincode)
        {
            throw new BadRequestException("Incorrect pincode");
        }

        // Remove pincode
        pincodeStore.RemovePincode(request.VerifyPincodeDto.Email!);

        // Process action
        if (request.VerifyPincodeDto.Action == PincodeAction.Signup)
        {
            var validateSignupDto = pincodeStore.GetValidateUser(request.VerifyPincodeDto.Email!);
            var user = mapper.Map<User>(validateSignupDto);

            var result = await userManager.CreateAsync(user, validateSignupDto.Password);
            if (!result.Succeeded)
            {
                throw new IdentityErrorException(result.Errors);
            }

            pincodeStore.RemoveValidateUser(request.VerifyPincodeDto.Email!);

            var roleResult = await userManager.AddToRoleAsync(user, "Player");
            if (!roleResult.Succeeded)
            {
                throw new IdentityErrorException(roleResult.Errors);
            }

            var userDto = mapper.Map<UserDto>(user);
            userDto.Token = await tokenService.CreateTokenAsync(user);

            return userDto;
        }
        else if (request.VerifyPincodeDto.Action == PincodeAction.VerifyEmail)
        {
            var user = await userManager.FindByEmailAsync(request.VerifyPincodeDto.Email!)
                ?? throw new UnauthorizedException("User not found");

            return await tokenService.CreateTokenAsync(user);
        }

        throw new BadRequestException("Invalid action");
    }
}
