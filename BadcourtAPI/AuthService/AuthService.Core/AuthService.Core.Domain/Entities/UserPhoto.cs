using System.ComponentModel.DataAnnotations.Schema;

namespace AuthService.Core.Domain.Entities;

[Table("UserPhotos")]
public class UserPhoto
{
    public Guid Id { get; set; }
    public required string Url { get; set; }
    public string? PublicId { get; set; }
    public bool IsMain { get; set; }

    // Navigation properties
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
}
