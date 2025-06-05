using System.Security.Claims;

namespace RealtimeService.Application.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static string GetUserId(this ClaimsPrincipal user)
    {
        var userId = user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new Exception("Cannot get user id from token");

        return userId;
    }
}
