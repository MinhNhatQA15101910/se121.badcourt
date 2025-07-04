using AuthService.Core.Domain.Enums;
using Microsoft.AspNetCore.Identity;

namespace AuthService.Core.Domain.Entities;

public class User : IdentityUser<Guid>
{
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? LastOnlineAt { get; set; } = DateTime.UtcNow;
    public ICollection<UserPhoto> Photos { get; set; } = [];
    public ICollection<UserRole> UserRoles { get; set; } = [];
    public UserState State { get; set; } = UserState.Active;
}
