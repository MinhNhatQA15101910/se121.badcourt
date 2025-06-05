using System.Security.Claims;

namespace PostService.Application.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal user)
    {
        var userId = user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new Exception("Cannot get user id from token");

        return Guid.Parse(userId);
    }

    public static string GetUsername(this ClaimsPrincipal user)
    {
        var username = user.FindFirstValue(ClaimTypes.Name)
            ?? throw new Exception("Cannot get username from token");

        return username;
    }

    public static List<string> GetRoles(this ClaimsPrincipal user)
    {
        var roles = user.FindAll(ClaimTypes.Role).Select(x => x.Value).ToList();

        return roles;
    }
}
