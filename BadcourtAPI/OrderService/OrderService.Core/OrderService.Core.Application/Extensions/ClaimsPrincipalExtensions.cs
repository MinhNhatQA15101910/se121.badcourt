using System.Security.Claims;

namespace OrderService.Core.Application.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal user)
    {
        var userId = user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new Exception("Cannot get user id from token");

        return Guid.Parse(userId);
    }

    public static List<string> GetRoles(this ClaimsPrincipal user)
    {
        var roles = user.FindAll(ClaimTypes.Role).Select(x => x.Value).ToList();

        return roles;
    }
}
