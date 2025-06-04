namespace SharedKernel.Params;

public class MessageParams : PaginationParams
{
    public required string CurrentUserId { get; set; }
    public required string GroupId { get; set; }
    public string OrderBy { get; set; } = "messageSent";
    public string SortBy { get; set; } = "desc";
}
