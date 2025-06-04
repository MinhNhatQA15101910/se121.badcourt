namespace SharedKernel.Params;

public class GroupParams : PaginationParams
{
    public required string UserId { get; set; }
    public string OrderBy { get; set; } = "updatedAt";
    public string SortBy { get; set; } = "desc";
}
