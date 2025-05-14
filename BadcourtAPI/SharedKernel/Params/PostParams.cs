namespace SharedKernel.Params;

public class PostParams : PaginationParams
{
    public string? UserId { get; set; }
    public string? Category { get; set; }
    public string OrderBy { get; set; } = "createdAt";
    public string SortBy { get; set; } = "desc";
}
