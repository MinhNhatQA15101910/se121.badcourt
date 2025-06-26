namespace SharedKernel.Params;

public class GroupParams : PaginationParams
{
    public string? Username { get; set; }
    public string OrderBy { get; set; } = "updatedAt";
    public string SortBy { get; set; } = "desc";
}
