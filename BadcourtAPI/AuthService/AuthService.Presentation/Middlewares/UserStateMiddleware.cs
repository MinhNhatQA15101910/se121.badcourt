using System.Security.Claims;
using AuthService.Core.Domain.Entities;
using AuthService.Core.Domain.Enums;
using Microsoft.AspNetCore.Identity;
using SharedKernel.Exceptions;

namespace AuthService.Presentation.Middlewares;

public class UserStateMiddleware(RequestDelegate next, ILogger<UserStateMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context, UserManager<User> userManager)
    {
        // If the user is authenticated
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var userIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier);

            if (userIdClaim != null && Guid.TryParse(userIdClaim.Value, out var userId))
            {
                var user = await userManager.FindByIdAsync(userId.ToString());

                if (user != null && user.State == UserState.Locked)
                {
                    logger.LogWarning("Blocked request from locked user: {UserId}", userId);
                    throw new UserLockedException(userId.ToString());
                }
            }
        }

        await next(context);
    }
}
