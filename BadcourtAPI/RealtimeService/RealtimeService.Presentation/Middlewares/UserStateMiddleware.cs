using System.Security.Claims;
using SharedKernel.Exceptions;

namespace RealtimeService.Presentation.Middlewares;

public class UserStateMiddleware(RequestDelegate next, ILogger<UserStateMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        // If the user is authenticated
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var userId = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userState = context.User.FindFirst("user_state")?.Value;

            if (!string.IsNullOrEmpty(userState) && userState.Equals("Locked", StringComparison.OrdinalIgnoreCase))
            {
                logger.LogWarning("Blocked request from locked user: {UserId}", userId);
                throw new UserLockedException(userId!.ToString());
            }
        }

        await next(context);
    }
}
