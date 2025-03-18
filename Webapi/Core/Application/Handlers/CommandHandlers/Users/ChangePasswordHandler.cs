using Application.Commands.Users;
using Domain.Entities;
using Domain.Exceptions;
using Microsoft.AspNetCore.Identity;

namespace Application.Handlers.CommandHandlers.Users;

public class ChangePasswordHandler(UserManager<User> userManager) : ICommandHandler<ChangePasswordCommand, bool>
{
    public async Task<bool> Handle(ChangePasswordCommand request, CancellationToken cancellationToken)
    {
        var user = await userManager.FindByIdAsync(request.ChangePasswordDto.UserId.ToString())
            ?? throw new UserNotFoundException(request.ChangePasswordDto.UserId);

        user.UpdatedAt = DateTime.UtcNow;
        var changePasswordResult = await userManager.ChangePasswordAsync(
            user, 
            request.ChangePasswordDto.CurrentPassword, 
            request.ChangePasswordDto.NewPassword
        );
        if (!changePasswordResult.Succeeded)
        {
            throw new IdentityErrorException(changePasswordResult.Errors);
        }

        return true;
    }
}
