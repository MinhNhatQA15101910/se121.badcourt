namespace FacilityService.Infrastructure.Configuration;

public class FacilityDatabaseSettings
{
    public required string ConnectionString { get; set; }
    public required string DatabaseName { get; set; }
    public required string FacilitiesCollectionName { get; set; }
}
