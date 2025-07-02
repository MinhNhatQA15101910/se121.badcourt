namespace SharedKernel.Params;

public class ManagerDashboardOrderParams : PaginationParams
{
    public string? FacilityId { get; set; }
    public string? CourtId { get; set; }
    public int? Year { get; set; } = null;
    public int? Month { get; set; } = null;
    public string? State { get; set; }
    public string TimeZoneId { get; set; } = "UTC"; // Default to UTC
    public DateTime HourFrom { get; set; } = DateTime.MinValue;
    public DateTime HourTo { get; set; } = DateTime.MaxValue;
    public string OrderBy { get; set; } = "createdAt";
    public string SortBy { get; set; } = "desc";
}
