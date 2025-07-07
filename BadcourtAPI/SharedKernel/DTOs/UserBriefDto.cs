namespace SharedKernel.DTOs;

public class UserBriefDto
{
    public Guid Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? PhotoUrl { get; set; }
    public DateTime? LastOnlineAt { get; set; }
    public DateTime CreatedAt { get; set; }
}
