using OrderService.Core.Domain.Enums;

namespace OrderService.Core.Domain.Entities;

public class Order
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string FacilityId { get; set; } = null!;
    public string CourtId { get; set; } = null!;
    public string FacilityName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public DateTimePeriod DateTimePeriod { get; set; } = null!;
    public decimal Price { get; set; }
    public OrderState State { get; set; } = OrderState.NotPlay;
    public string ImageUrl { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
