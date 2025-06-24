using FacilityService.Core.Domain.Enums;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace FacilityService.Core.Domain.Entities;

public class Facility
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;

    [BsonRepresentation(BsonType.String)]
    public Guid UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string? UserImageUrl { get; set; }
    public string FacilityName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? FacebookUrl { get; set; }
    public string Policy { get; set; } = string.Empty;
    public int CourtsAmount { get; set; }
    public decimal MinPrice { get; set; }
    public decimal MaxPrice { get; set; }
    public string DetailAddress { get; set; } = string.Empty;
    public string Province { get; set; } = string.Empty;

    [BsonElement("location")]
    public Location Location { get; set; } = new Location();

    public float RatingAvg { get; set; }
    public int TotalRatings { get; set; }
    public Active? ActiveAt { get; set; }

    [BsonRepresentation(BsonType.String)]
    public FacilityState State { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime RegisteredAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public IEnumerable<FacilityPhoto> Photos { get; set; } = [];
    public ManagerInfo ManagerInfo { get; set; } = null!;

    [BsonIgnoreIfNull]
    public double Distance { get; set; }
    [BsonIgnoreIfNull]
    public decimal AvgPrice { get; set; }
}
