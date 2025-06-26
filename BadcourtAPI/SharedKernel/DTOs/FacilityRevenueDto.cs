namespace SharedKernel.DTOs;

public class FacilityRevenueDto
{
    public string FacilityId { get; set; } = null!;
    public string FacilityName { get; set; } = string.Empty;
    public decimal Revenue { get; set; }
}
