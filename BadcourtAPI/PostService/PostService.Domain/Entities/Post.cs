using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using PostService.Domain.Enums;

namespace PostService.Domain.Entities;

public class Post
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;

    [BsonRepresentation(BsonType.String)]
    public Guid PublisherId { get; set; }
    public string PublisherUsername { get; set; } = string.Empty;
    public string PublisherImageUrl { get; set; } = string.Empty;
    [BsonRepresentation(BsonType.String)]
    public UserState PublisherState { get; set; } = UserState.Active;
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;

    [BsonRepresentation(BsonType.String)]
    public PostCategory Category { get; set; } = PostCategory.Sharing;
    public IEnumerable<File> Resources { get; set; } = [];
    public int LikesCount { get; set; }
    public IEnumerable<string> LikedUsers { get; set; } = [];
    public int CommentsCount { get; set; }
    public IEnumerable<string> CommentedUsers { get; set; } = [];
    public int ReportsCount { get; set; }
    public List<string> ReportUsers { get; set; } = [];
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
