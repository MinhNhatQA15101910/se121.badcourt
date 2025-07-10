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

        // Docker
        var facilityData = await File.ReadAllTextAsync(
            "Data/FacilitySeedData.json"
        );

        // Development
        // var facilityData = await File.ReadAllTextAsync(
        //     "../FacilityService.Infrastructure/FacilityService.Infrastructure.Persistence/Data/FacilitySeedData.json"
        // );

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
