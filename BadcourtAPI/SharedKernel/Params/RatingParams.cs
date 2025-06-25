namespace SharedKernel.Params;

public class RatingParams : PaginationParams
{
    public Guid? UserId { get; set; }
    public string? FacilityId { get; set; }
    public int MinStars { get; set; } = 1;
    public int MaxStars { get; set; } = 5;
    public string OrderBy { get; set; } = "createdAt";
    public string SortBy { get; set; } = "desc";
}
