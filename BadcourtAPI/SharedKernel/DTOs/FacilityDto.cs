namespace SharedKernel.DTOs;

public class FacilityDto
{
    public string Id { get; set; } = null!;
    public Guid UserId { get; set; }
    public string FacilityName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? FacebookUrl { get; set; }
    public string Policy { get; set; } = string.Empty;
    public int CourtsAmount { get; set; }
    public decimal MinPrice { get; set; }
    public decimal MaxPrice { get; set; }
    public string DetailAddress { get; set; } = string.Empty;
    public string Province { get; set; } = string.Empty;
    public LocationDto? Location { get; set; }
    public float RatingAvg { get; set; }
    public int TotalRatings { get; set; }
    public ActiveDto? ActiveAt { get; set; }
    public string State { get; set; } = string.Empty;
    public DateTime RegisteredAt { get; set; } = DateTime.UtcNow;
    public IEnumerable<PhotoDto> Photos { get; set; } = [];
    public ManagerInfoDto ManagerInfo { get; set; } = null!;
}
