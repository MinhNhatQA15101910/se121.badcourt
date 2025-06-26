using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace RealtimeService.Domain.Entities;

public class Group
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;
    public string Name { get; set; } = string.Empty;
    public List<string> UserIds { get; set; } = [];
    public List<string> Usernames { get; set; } = [];
    public bool HasMessage { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
