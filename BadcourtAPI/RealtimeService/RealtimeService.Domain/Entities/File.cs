using System;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using RealtimeService.Domain.Enums;

namespace RealtimeService.Domain.Entities;

public class File
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;
    public string Url { get; set; } = string.Empty;
    public string? PublicId { get; set; }
    public bool IsMain { get; set; }

    [BsonRepresentation(BsonType.String)]
    public FileType FileType { get; set; }
}
