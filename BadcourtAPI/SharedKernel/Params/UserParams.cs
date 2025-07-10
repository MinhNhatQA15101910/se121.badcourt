namespace SharedKernel.Params;

public class UserParams : PaginationParams
{
    public string? Search { get; set; }
    public string? Role { get; set; }
    public string OrderBy { get; set; } = "email";
    public string SortBy { get; set; } = "asc";
}
