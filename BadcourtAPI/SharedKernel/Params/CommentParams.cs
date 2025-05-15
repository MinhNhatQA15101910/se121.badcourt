namespace SharedKernel.Params;

public class CommentParams : PaginationParams
{
    public string? PostId { get; set; }
    public string OrderBy { get; set; } = "createdAt";
    public string SortBy { get; set; } = "desc";
}
