using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using PostService.Domain.Enums;

namespace PostService.Domain.Entities;

public class File
{
    public string Url { get; set; } = string.Empty;
    public string? PublicId { get; set; }
    public bool IsMain { get; set; }

    [BsonRepresentation(BsonType.String)]
    public FileType FileType { get; set; }
}
