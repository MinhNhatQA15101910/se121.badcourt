using Microsoft.AspNetCore.Identity;

namespace Domain.Entities;

public class Role : IdentityRole<Guid>
{
    public ICollection<UserRole> UserRoles { get; set; } = [];
}
