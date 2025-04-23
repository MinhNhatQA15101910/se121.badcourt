namespace SharedKernel.Params;

public class CourtParams : PaginationParams
{
    public string? FacilityId { get; set; }
    public string OrderBy { get; set; } = "registeredAt";
    public string SortBy { get; set; } = "desc";
}
