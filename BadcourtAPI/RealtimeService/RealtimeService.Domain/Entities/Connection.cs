namespace RealtimeService.Domain.Entities;

public class Connection
{
    public string ConnectionId { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string? GroupId { get; set; }
}
