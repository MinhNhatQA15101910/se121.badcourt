using Application.Commands.Auth;
using Application.Interfaces;
using Application.Notifications.Auth;
using Application.Services;
using Domain.Entities;
using Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Application.Handlers.CommandHandlers.Auth;

public class ValidateEmailHandler(
    UserManager<User> userManager,
    PincodeStore pincodeStore,
    ITokenService tokenService,
    IMediator mediator
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
        await mediator.Publish(
            new EmailValidatedNotification(request.ValidateEmailDto.Email, pincode),
            cancellationToken
        );

        return tokenService.CreateVerifyPincodeToken(request.ValidateEmailDto.Email, PincodeAction.VerifyEmail.ToString());
    }

    private async Task<bool> UserExists(string email)
    {
        return await userManager.Users.AnyAsync(x => x.NormalizedEmail == email.ToUpper());
    }
}
