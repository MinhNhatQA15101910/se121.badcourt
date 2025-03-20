using FacilityService.Core.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace FacilityService.Infrastructure.Persistence;

public class DataContext(DbContextOptions<DataContext> options) : DbContext(options)
{
    public DbSet<Facility> Facilities { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

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

        builder.Entity<Facility>()
            .HasOne(o => o.ManagerInfo)
            .WithOne()
            .HasForeignKey<Facility>(o => o.ManagerInfoId);

        builder.Entity<ManagerInfo>(managerInfo =>
        {
            managerInfo.OwnsOne(m => m.CitizenImageFront);
            managerInfo.OwnsOne(m => m.CitizenImageBack);
            managerInfo.OwnsOne(m => m.BankCardFront);
            managerInfo.OwnsOne(m => m.BankCardBack);
        });
    }
}
