using System.Text.Json;
using Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Persistence;

public class Seed
{
    public static async Task SeedUsersAsync(
        UserManager<User> userManager,
        RoleManager<Role> roleManager
    )
    {
        if (await userManager.Users.AnyAsync()) return;

        var userData = await File.ReadAllTextAsync("../Infrastructure/Persistence/Data/UserSeedData.json");

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
                new() { Name = "User" },
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

            if (index < 8)
            {
                await userManager.AddToRoleAsync(user, "User");
            }
            else
            {
                await userManager.AddToRoleAsync(user, "Admin");
            }

            index++;
        }
    }
}
