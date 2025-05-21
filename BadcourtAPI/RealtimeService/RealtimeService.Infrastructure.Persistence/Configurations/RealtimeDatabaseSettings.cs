namespace RealtimeService.Infrastructure.Persistence.Configurations;

public class RealtimeDatabaseSettings
{
    public required string ConnectionString { get; set; }
    public required string DatabaseName { get; set; }
    public required string MessagesCollectionName { get; set; }
    public required string GroupsCollectionName { get; set; }
    public required string ConnectionsCollectionName { get; set; }
}
