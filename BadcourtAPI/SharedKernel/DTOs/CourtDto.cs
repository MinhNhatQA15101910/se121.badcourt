namespace SharedKernel.DTOs;

public class CourtDto
{
    public string Id { get; set; } = null!;
    public string CourtName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public string State { get; set; } = string.Empty;
    public List<DateTimePeriodDto> OrderPeriods { get; set; } = [];
    public List<DateTimePeriodDto> InactivePeriods { get; set; } = [];
    public DateTime CreatedAt { get; set; }
}
