using Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Persistence;

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
    public DbSet<Facility> Facilities { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<User>()
            .HasMany(x => x.UserRoles)
            .WithOne(x => x.User)
            .HasForeignKey(x => x.UserId)
            .IsRequired();

        builder.Entity<Role>()
            .HasMany(x => x.UserRoles)
            .WithOne(x => x.Role)
            .HasForeignKey(x => x.RoleId)
            .IsRequired();

        builder.Entity<Facility>()
            .OwnsOne(f => f.ManagerInfo, mi =>
            {
                mi.OwnsOne(m => m.CitizenImageFront);
                mi.OwnsOne(m => m.CitizenImageBack);
                mi.OwnsOne(m => m.BankCardFront);
                mi.OwnsOne(m => m.BankCardBack);
                mi.OwnsMany(m => m.BusinessLicenseImages);
            });

        builder.Entity<Facility>()
            .OwnsOne(f => f.ActiveAt, aa =>
            {
                aa.OwnsOne(x => x.Monday);
                aa.OwnsOne(x => x.Tuesday);
                aa.OwnsOne(x => x.Wednesday);
                aa.OwnsOne(x => x.Thursday);
                aa.OwnsOne(x => x.Friday);
                aa.OwnsOne(x => x.Saturday);
                aa.OwnsOne(x => x.Sunday);
            });
    }
}
