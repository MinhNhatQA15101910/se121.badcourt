namespace OrderService.Core.Domain.Entities;

public class Rating
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string FacilityId { get; set; } = null!;
    public int Stars { get; set; }
    public string Feedback { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
