using System.Text.Json;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;

namespace RealtimeService.Infrastructure.Persistence.Data;

public class Seed
{
    public static async Task SeedUsersAsync(
        IUserRepository userRepository
    )
    {
        if (await userRepository.AnyAsync()) return;

        var userData = await System.IO.File.ReadAllTextAsync(
            "../RealtimeService.Infrastructure.Persistence/Data/UserSeedData.json"
        );

        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        var users = JsonSerializer.Deserialize<List<User>>(userData, options);

        if (users == null) return;

        foreach (var user in users)
        {
            Console.WriteLine("Adding user: " + user.Username);
            await userRepository.AddUserAsync(user);
        }
    }

    public static async Task SeedCourtsAsync(
        ICourtRepository courtRepository
    )
    {
        if (await courtRepository.AnyAsync()) return;

        var courtData = await System.IO.File.ReadAllTextAsync(
            "../RealtimeService.Infrastructure.Persistence/Data/CourtSeedData.json"
        );

        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        var courts = JsonSerializer.Deserialize<List<Court>>(courtData, options);

        if (courts == null) return;

        foreach (var court in courts)
        {
            Console.WriteLine("Adding court: " + court.CourtName);
            await courtRepository.AddCourtAsync(court);
        }
    }
}
