using Microsoft.AspNetCore.Identity;

namespace BadCourtAPI.Entities;

public class User : IdentityUser<Guid>
{
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public ICollection<UserRole> UserRoles { get; set; } = [];
}
