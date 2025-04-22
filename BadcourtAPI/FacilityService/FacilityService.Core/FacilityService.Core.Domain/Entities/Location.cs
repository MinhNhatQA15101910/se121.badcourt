using MongoDB.Bson.Serialization.Attributes;

namespace FacilityService.Core.Domain.Entities;

public class Location
{
    [BsonElement("type")]
    public string Type { get; set; } = null!;

    [BsonElement("coordinates")]
    public double[] Coordinates { get; set; } = [];
}
