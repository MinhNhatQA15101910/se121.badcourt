using AuthService.Core.Application.Commands;
using AuthService.Core.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

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
