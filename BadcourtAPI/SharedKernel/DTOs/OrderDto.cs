namespace SharedKernel.DTOs;

public class OrderDto
{
    public Guid Id { get; set; }
    public string FacilityName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string State { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public DateTimePeriodDto DateTimePeriod { get; set; } = new DateTimePeriodDto();
    public DateTime CreatedAt { get; set; }
}
