using System.Text.Json;
using AuthService.Core.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace AuthService.Infrastructure.Persistence;

public class Seed
{
    public static async Task SeedUsersAsync(
        UserManager<User> userManager,
        RoleManager<Role> roleManager
    )
    {
        if (await userManager.Users.AnyAsync()) return;

        var userData = await File.ReadAllTextAsync(
            "Data/UserSeedData.json"
        );

        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        var users = JsonSerializer.Deserialize<List<User>>(userData, options);

        if (users == null) return;

        if (!await roleManager.Roles.AnyAsync())
        {
            var roles = new List<Role>
            {
                new() { Name = "Player" },
                new() { Name = "Manager" },
                new() { Name = "Admin" },
            };

            foreach (var role in roles)
            {
                await roleManager.CreateAsync(role);
            }
        }

        int index = 0;
        foreach (var user in users)
        {
            Console.WriteLine(index.ToString());
            await userManager.CreateAsync(user, "Pa$$w0rd");

            if (index < 2)
            {
                await userManager.AddToRoleAsync(user, "Player");
            }
            else if (index >= 2 && index < 8)
            {
                await userManager.AddToRoleAsync(user, "Manager");
            }
            else
            {
                await userManager.AddToRoleAsync(user, "Admin");
            }

            index++;
        }
    }
}
