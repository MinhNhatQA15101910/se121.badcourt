namespace SharedKernel.Params;

public class PostParams : PaginationParams
{
    public string? PublisherId { get; set; }
    public string? Category { get; set; }
    public string? Search { get; set; }
    public string OrderBy { get; set; } = "createdAt";
    public string SortBy { get; set; } = "desc";
}
