namespace SharedKernel.DTOs;

public class CourtRevenueDto
{
    public string CourtId { get; set; } = null!;
    public string CourtName { get; set; } = string.Empty;
    public decimal Revenue { get; set; }
}
