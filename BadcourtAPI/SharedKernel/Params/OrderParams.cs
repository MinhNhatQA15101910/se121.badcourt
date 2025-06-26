namespace SharedKernel.Params;

public class OrderParams : PaginationParams
{
    public string? FacilityId { get; set; }
    public string? CourtId { get; set; }
    public string? State { get; set; }
    public DateTime HourFrom { get; set; } = DateTime.MinValue;
    public DateTime HourTo { get; set; } = DateTime.MaxValue;
    public string OrderBy { get; set; } = "createdAt";
    public string SortBy { get; set; } = "desc";
}
