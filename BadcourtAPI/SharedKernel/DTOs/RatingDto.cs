namespace SharedKernel.DTOs;

public class RatingDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Username { get; set; } = string.Empty;
    public string UserImageUrl { get; set; } = string.Empty;
    public string FacilityId { get; set; } = null!;
    public int Stars { get; set; }
    public string Feedback { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
