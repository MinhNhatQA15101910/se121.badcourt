namespace CourtService.Infrastructure.Configuration;

public class CourtDatabaseSettings
{
    public required string ConnectionString { get; set; }
    public required string DatabaseName { get; set; }
    public required string CourtsCollectionName { get; set; }
}
