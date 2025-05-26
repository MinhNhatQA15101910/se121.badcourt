using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using RealtimeService.Domain.Enums;

namespace RealtimeService.Domain.Entities;

public class NotificationData
{
    public string? CourtId { get; set; }
    public string? RoomId { get; set; }
}

public class Notification
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = null!;
    public string UserId { get; set; } = null!;

    [BsonRepresentation(BsonType.String)]
    public NotificationType Type { get; set; } = NotificationType.None;
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public NotificationData Data { get; set; } = new NotificationData();
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
