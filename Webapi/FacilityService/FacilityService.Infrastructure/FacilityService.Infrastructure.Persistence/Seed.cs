using System.Text.Json;
using FacilityService.Core.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace FacilityService.Infrastructure.Persistence;

public class Seed
{
    public static async Task SeedFacilitiesAsync(
        DataContext context
    )
    {
        if (await context.Facilities.AnyAsync()) return;

        var userData = await File.ReadAllTextAsync(
            "../FacilityService.Infrastructure/FacilityService.Infrastructure.Persistence/Data/FacilitySeedData.json"
        );

        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        var facilities = JsonSerializer.Deserialize<List<Facility>>(userData, options);

        if (facilities == null) return;

        foreach (var facility in facilities)
        {
            context.Facilities.Add(facility);
        }

        await context.SaveChangesAsync();
    }
}
