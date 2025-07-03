namespace SharedKernel.Params;

public class AdminDashboardFacilityRevenueParams : PaginationParams
{
    public DateOnly StartDate { get; set; } = DateOnly.MinValue;
    public DateOnly EndDate { get; set; } = DateOnly.MaxValue;
}
