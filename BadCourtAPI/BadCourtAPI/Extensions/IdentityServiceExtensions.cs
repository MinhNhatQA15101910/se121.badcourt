using BadCourtAPI.Data;
using BadCourtAPI.Entities;
using Microsoft.AspNetCore.Identity;

namespace BadCourtAPI.Extensions;

public static class IdentityServiceExtensions
{
    public static IServiceCollection AddIdentityServices(this IServiceCollection services)
    {
        services.AddIdentityCore<User>(options =>
        {
            options.Password.RequireNonAlphanumeric = false;
        })
            .AddRoles<Role>()
            .AddRoleManager<RoleManager<Role>>()
            .AddEntityFrameworkStores<DataContext>();

        return services;
    }
}
