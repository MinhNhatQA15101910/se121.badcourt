using System.Text.Json;
using CourtService.Core.Domain.Entities;
using CourtService.Core.Domain.Repositories;

namespace CourtService.Infrastructure.Persistence;

public class Seed
{
    public static async Task SeedCourtsAsync(
        ICourtRepository courtRepository
    )
    {
        if (await courtRepository.AnyAsync()) return;

        var courtData = await File.ReadAllTextAsync(
            "../CourtService.Infrastructure/CourtService.Infrastructure.Persistence/Data/CourtSeedData.json"
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
