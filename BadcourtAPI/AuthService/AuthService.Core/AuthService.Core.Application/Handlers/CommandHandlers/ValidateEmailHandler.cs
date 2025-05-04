using AuthService.Core.Application.Commands;
using AuthService.Core.Application.Interfaces;
using AuthService.Core.Application.Services;
using AuthService.Core.Domain.Entities;
using AuthService.Core.Domain.Enums;
using MassTransit;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using SharedKernel.Events;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class ValidateEmailHandler(
    UserManager<User> userManager,
    PincodeStore pincodeStore,
    ITokenService tokenService,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<ValidateEmailCommand, object>
{
    public async Task<object> Handle(ValidateEmailCommand request, CancellationToken cancellationToken)
    {
        if (!await UserExists(request.ValidateEmailDto.Email))
        {
            return false;
        }

        // Add to pincode map
        var pincode = PincodeStore.GeneratePincode();
        pincodeStore.AddPincode(request.ValidateEmailDto.Email, pincode);

        // Send pincode email
        await publishEndpoint.Publish(
            new EmailValidatedEvent(request.ValidateEmailDto.Email, pincode),
            cancellationToken
        );

        return tokenService.CreateVerifyPincodeToken(request.ValidateEmailDto.Email, PincodeAction.VerifyEmail.ToString());
    }

    private async Task<bool> UserExists(string email)
    {
        return await userManager.Users.AnyAsync(x => x.NormalizedEmail == email.ToUpper());
    }
}
