using System.Text.Json;
using FacilityService.Core.Domain.Entities;
using FacilityService.Core.Domain.Repositories;

namespace FacilityService.Infrastructure.Persistence;

public class Seed
{
    public static async Task SeedFacilitiesAsync(
        IFacilityRepository facilityRepository
    )
    {
        if (await facilityRepository.AnyAsync()) return;

        var facilityData = await File.ReadAllTextAsync(
            "Data/FacilitySeedData.json"
        );

        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        var facilities = JsonSerializer.Deserialize<List<Facility>>(facilityData, options);

        if (facilities == null) return;

        foreach (var facility in facilities)
        {
            Console.WriteLine("Adding facility: " + facility.FacilityName);
            await facilityRepository.AddFacilityAsync(facility);
        }
    }
}
