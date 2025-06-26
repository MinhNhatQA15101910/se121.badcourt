using Microsoft.AspNetCore.Http;

namespace ManagerService.Application.Extensions;

public static class HttpContextExtensions
{
    public static string GetBearerToken(this HttpContext context)
    {
        if (context.Request.Headers.TryGetValue("Authorization", out var authHeader))
        {
            if (authHeader.ToString().StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            {
                return authHeader.ToString()["Bearer ".Length..].Trim();
            }
        }

        throw new InvalidOperationException("Bearer token not found in the request headers.");
    }
}
