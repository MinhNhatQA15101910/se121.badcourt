using Microsoft.EntityFrameworkCore;
using OrderService.Core.Domain.Entities;

namespace OrderService.Infrastructure.Persistence;

public class DataContext(DbContextOptions options) : DbContext(options)
{
    public DbSet<Order> Orders { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Order>()
            .OwnsOne(o => o.DateTimePeriod);
    }
}
