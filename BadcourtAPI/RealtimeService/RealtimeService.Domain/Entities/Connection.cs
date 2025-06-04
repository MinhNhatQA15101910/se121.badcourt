using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace RealtimeService.Domain.Entities;

public class Connection
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;
    public string ConnectionId { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string GroupId { get; set; } = null!;
}
