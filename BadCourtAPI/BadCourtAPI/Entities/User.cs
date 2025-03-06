using Microsoft.AspNetCore.Identity;

namespace BadCourtAPI.Entities;

public class User : IdentityUser<Guid>
{
    public required string FullName { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public ICollection<UserPhoto> Photos { get; set; } = [];
    public ICollection<UserRole> UserRoles { get; set; } = [];
}
