namespace CourtService.Core.Application.DTOs;

public class AddCourtDto
{
    public string FacilityId { get; set; } = string.Empty;
    public string CourtName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
}
