using BadCourtAPI.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace BadCourtAPI.Data;

public class DataContext(DbContextOptions options) : 
IdentityDbContext<
    User,
    Role,
    Guid,
    IdentityUserClaim<Guid>,
    UserRole,
    IdentityUserLogin<Guid>,
    IdentityRoleClaim<Guid>,
    IdentityUserToken<Guid>
>(options)
{
}
