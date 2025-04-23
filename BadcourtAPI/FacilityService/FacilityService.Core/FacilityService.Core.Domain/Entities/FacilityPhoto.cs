using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace FacilityService.Core.Domain.Entities;

public class FacilityPhoto
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;
    public required string Url { get; set; }
    public string? PublicId { get; set; }
    public bool IsMain { get; set; }
}
