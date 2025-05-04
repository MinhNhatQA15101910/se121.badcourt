using System.Security.Claims;

namespace FacilityService.Presentation.Extensions;

public static class ClaimPrincipalExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal user)
    {
        var userId = user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new Exception("Cannot get user id from token");

        return Guid.Parse(userId);
    }
}
