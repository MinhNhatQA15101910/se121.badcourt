using OrderService.Core.Domain.Enums;

namespace OrderService.Core.Domain.Entities;

public class Order
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Username { get; set; } = string.Empty;
    public string? UserImageUrl { get; set; }
    public string FacilityOwnerId { get; set; } = null!;
    public string FacilityOwnerUsername { get; set; } = string.Empty;
    public string? FacilityOwnerImageUrl { get; set; } = string.Empty;
    public string FacilityId { get; set; } = null!;
    public string FacilityName { get; set; } = string.Empty;
    public string CourtId { get; set; } = null!;
    public string CourtName { get; set; } = string.Empty;
    public string Province { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public DateTimePeriod DateTimePeriod { get; set; } = null!;
    public decimal Price { get; set; }
    public OrderState State { get; set; } = OrderState.NotPlay;
    public string ImageUrl { get; set; } = string.Empty;
    public string PaymentIntentId { get; set; } = null!;
    public Rating? Rating { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
