namespace SharedKernel.DTOs;

public class CourtDto
{
    public string Id { get; set; } = null!;
    public string CourtName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public string State { get; set; } = string.Empty;
    public List<TimePeriodDto> OrderPeriods { get; set; } = [];
    public List<TimePeriodDto> InactivePeriods { get; set; } = [];
    public DateTime CreatedAt { get; set; }
}
