namespace CourtService.Core.Application.DTOs;

public class UpdateCourtDto
{
    public string CourtName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
}
