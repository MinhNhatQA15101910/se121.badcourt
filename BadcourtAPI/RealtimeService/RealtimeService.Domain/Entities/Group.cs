using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace RealtimeService.Domain.Entities;

public class Group
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;
    public string Name { get; set; } = string.Empty;
    public List<Connection> Connections { get; set; } = [];
}
