namespace SharedKernel.Params;

public class FacilityParams : PaginationParams
{
    public string? UserId { get; set; }
    public string? FacilityName { get; set; }
    public double Lat { get; set; }
    public double Lon { get; set; }
    public string? Province { get; set; }
    public decimal MinPrice { get; set; } = decimal.MinValue;
    public decimal MaxPrice { get; set; } = decimal.MaxValue;
    public string? Search { get; set; }
    public string OrderBy { get; set; } = "registeredAt";
    public string SortBy { get; set; } = "desc";
}
