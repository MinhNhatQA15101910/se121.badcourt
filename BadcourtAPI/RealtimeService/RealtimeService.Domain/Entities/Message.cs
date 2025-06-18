using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace RealtimeService.Domain.Entities;

public class Message
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;
    public string GroupId { get; set; } = null!;
    public string SenderId { get; set; } = null!;
    public string SenderUsername { get; set; } = string.Empty;
    public string SenderImageUrl { get; set; } = string.Empty;
    public string ReceiverId { get; set; } = null!;
    public string Content { get; set; } = string.Empty;
    public List<File> Resources { get; set; } = [];
    public DateTime? DateRead { get; set; }
    public DateTime MessageSent { get; set; } = DateTime.UtcNow;
}
