using Microsoft.AspNetCore.Identity;

namespace BadCourtAPI.Entities;

public class Role : IdentityRole<Guid>
{
    public ICollection<UserRole> UserRoles { get; set; } = [];
}
