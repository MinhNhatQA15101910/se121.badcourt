using OrderService.Core.Domain.Enums;

namespace OrderService.Core.Domain.Entities;

public class Order
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string CourtId { get; set; } = null!;
    public string Address { get; set; } = string.Empty;
    public DateTimePeriod DateTimePeriod { get; set; } = null!;
    public decimal Price { get; set; }
    public OrderState State { get; set; }
    public Photo Image { get; set; } = null!;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
