using System.Security.Claims;

namespace FacilityService.Core.Application.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal user)
    {
        var userId = user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new Exception("Cannot get user id from token");

        return Guid.Parse(userId);
    }
}
