using AuthService.Core.Application.Commands;
using AuthService.Core.Application.Interfaces;
using AuthService.Core.Application.Notifications;
using AuthService.Core.Application.Services;
using AuthService.Core.Domain.Entities;
using AuthService.Core.Domain.Enums;
using AuthService.Core.Domain.Exceptions;
using MediatR;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class ValidateSignupHandler(
    UserManager<User> userManager,
    PincodeStore pincodeStore,
    ITokenService tokenService,
    IMediator mediator
) : ICommandHandler<ValidateSignupCommand, string>
{
    public async Task<string> Handle(ValidateSignupCommand request, CancellationToken cancellationToken)
    {
        // Check if email already exists
        if (await UserExists(request.ValidateSignupDto.Email))
        {
            throw new BadRequestException("Email already exists.");
        }

        // Check if password is valid
        var result = await userManager.PasswordValidators.First().ValidateAsync(
            userManager,
            null!,
            request.ValidateSignupDto.Password
        );

        if (!result.Succeeded)
        {
            throw new IdentityErrorException(result.Errors);
        }

        // Add to pincode map
        var pincode = PincodeStore.GeneratePincode();
        pincodeStore.AddPincode(request.ValidateSignupDto.Email, pincode);

        // Add to validate user map
        pincodeStore.AddValidateUser(request.ValidateSignupDto.Email, request.ValidateSignupDto);

        // Send pincode email
        await mediator.Publish(
            new SignupValidatedNotification(request.ValidateSignupDto.Username, request.ValidateSignupDto.Email, pincode),
            cancellationToken
        );

        return tokenService.CreateVerifyPincodeToken(request.ValidateSignupDto.Email, PincodeAction.Signup.ToString());
    }

    private async Task<bool> UserExists(string email)
    {
        return await userManager.Users.AnyAsync(x => x.NormalizedEmail == email.ToUpper());
    }
}
