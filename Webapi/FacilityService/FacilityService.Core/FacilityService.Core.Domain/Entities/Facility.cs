using FacilityService.Core.Domain.Enums;

namespace FacilityService.Core.Domain.Entities;

public class Facility
{
    public Guid Id { get; set; }
    public string FacilityName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? FacebookUrl { get; set; }
    public string Policy { get; set; } = string.Empty;
    public int CourtsAmount { get; set; }
    public decimal MinPrice { get; set; }
    public decimal MaxPrice { get; set; }
    public string DetailAddress { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public float RatingAvg { get; set; }
    public int TotalRatings { get; set; }
    public Active ActiveAt { get; set; } = new Active();
    public FacilityState State { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public IEnumerable<FacilityPhoto> Photos { get; set; } = [];

    // Navigation properties
    public Guid ManagerInfoId { get; set; }
    public ManagerInfo ManagerInfo { get; set; } = null!;
}
