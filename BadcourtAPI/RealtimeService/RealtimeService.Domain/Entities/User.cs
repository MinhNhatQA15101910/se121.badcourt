namespace RealtimeService.Domain.Entities;

public class User
{
    public string Id { get; set; } = null!;

    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public List<UserPhoto> Photos { get; set; } = [];
    public List<string> Roles { get; set; } = [];

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
