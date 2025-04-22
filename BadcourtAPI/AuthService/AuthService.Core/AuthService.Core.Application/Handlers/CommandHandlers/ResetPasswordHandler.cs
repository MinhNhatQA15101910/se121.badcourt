using AuthService.Core.Application.Commands;
using AuthService.Core.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class ResetPasswordHandler(UserManager<User> userManager) : ICommandHandler<ResetPasswordCommand, bool>
{
    public async Task<bool> Handle(ResetPasswordCommand request, CancellationToken cancellationToken)
    {
        // Get user
        var user = await userManager.FindByIdAsync(request.ResetPasswordDto.UserId.ToString()!)
            ?? throw new UnauthorizedException("User not found");

        // Reset password
        user.UpdatedAt = DateTime.UtcNow;
        user.PasswordHash = userManager.PasswordHasher.HashPassword(user, request.ResetPasswordDto.NewPassword);

        var result = await userManager.UpdateAsync(user);
        if (!result.Succeeded)
        {
            throw new BadRequestException("Failed to reset password");
        }

        return true;
    }
}
