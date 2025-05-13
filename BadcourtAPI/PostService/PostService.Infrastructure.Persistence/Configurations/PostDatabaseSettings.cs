namespace PostService.Infrastructure.Persistence.Configurations;

public class PostDatabaseSettings
{
    public required string ConnectionString { get; set; }
    public required string DatabaseName { get; set; }
    public required string PostsCollectionName { get; set; }
    public required string CommentsCollectionName { get; set; }
}
