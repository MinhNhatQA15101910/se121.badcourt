namespace SharedKernel.Params;

public class NotificationParams : PaginationParams
{
    public required string UserId { get; set; }
    public string OrderBy { get; set; } = "createdAt";
    public string SortBy { get; set; } = "desc";
}
