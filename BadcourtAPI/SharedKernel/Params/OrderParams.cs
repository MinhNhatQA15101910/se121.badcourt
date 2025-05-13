namespace SharedKernel.Params;

public class OrderParams : PaginationParams
{
    public string? CourtId { get; set; }
    public string? OrderState { get; set; }
    public string OrderBy { get; set; } = "createdAt";
    public string SortBy { get; set; } = "desc";
}
