using Microsoft.AspNetCore.Identity;

namespace AuthService.Core.Domain.Entities;

public class Role : IdentityRole<Guid>
{
    public ICollection<UserRole> UserRoles { get; set; } = [];
}
