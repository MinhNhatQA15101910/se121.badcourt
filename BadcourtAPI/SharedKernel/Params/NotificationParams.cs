namespace SharedKernel.Params;

public class NotificationParams : PaginationParams
{
    public string OrderBy { get; set; } = "createdAt";
    public string SortBy { get; set; } = "desc";
}
