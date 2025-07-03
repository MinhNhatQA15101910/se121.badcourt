namespace SharedKernel.Params;

public class AdminDashboardProvinceRevenueParams : PaginationParams
{
    public DateOnly StartDate { get; set; } = DateOnly.MinValue;
    public DateOnly EndDate { get; set; } = DateOnly.MaxValue;
}
