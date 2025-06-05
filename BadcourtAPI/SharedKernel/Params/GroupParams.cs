namespace SharedKernel.Params;

public class GroupParams : PaginationParams
{
    public string OrderBy { get; set; } = "updatedAt";
    public string SortBy { get; set; } = "desc";
}
