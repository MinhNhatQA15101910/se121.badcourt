using CourtService.Core.Domain.Enums;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace CourtService.Core.Domain.Entities;

public class Court
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;
    public string UserId { get; set; } = null!;

    [BsonRepresentation(BsonType.String)]
    public UserState UserState { get; set; } = UserState.Active;
    public string FacilityId { get; set; } = null!;
    public string CourtName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public string State { get; set; } = string.Empty;
    public IEnumerable<DateTimePeriod> OrderPeriods { get; set; } = [];
    public IEnumerable<DateTimePeriod> InactivePeriods { get; set; } = [];
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
