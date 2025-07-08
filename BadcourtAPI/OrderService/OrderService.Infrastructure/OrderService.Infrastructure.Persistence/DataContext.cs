using Microsoft.EntityFrameworkCore;
using OrderService.Core.Domain.Entities;
using OrderService.Core.Domain.Enums;

namespace OrderService.Infrastructure.Persistence;

public class DataContext(DbContextOptions options) : DbContext(options)
{
    public DbSet<Order> Orders { get; set; }
    public DbSet<Rating> Ratings { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Order>(entity =>
        {
            entity.Property(o => o.State)
                .HasConversion<string>()
                .IsRequired();
        });

        modelBuilder.Entity<Order>()
            .HasQueryFilter(o => o.State != OrderState.Pending);

        modelBuilder.Entity<Order>()
            .OwnsOne(o => o.DateTimePeriod);

        modelBuilder.Entity<Order>()
            .HasOne(o => o.Rating);
    }
}
