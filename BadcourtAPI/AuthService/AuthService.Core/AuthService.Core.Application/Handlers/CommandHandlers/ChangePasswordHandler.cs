using AuthService.Core.Application.Commands;
using AuthService.Core.Application.Extensions;
using AuthService.Core.Domain.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class ChangePasswordHandler(
    UserManager<User> userManager,
    IHttpContextAccessor httpContextAccessor
) : ICommandHandler<ChangePasswordCommand, bool>
{
    public async Task<bool> Handle(ChangePasswordCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        var user = await userManager.FindByIdAsync(userId.ToString())
            ?? throw new UserNotFoundException(userId);

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
