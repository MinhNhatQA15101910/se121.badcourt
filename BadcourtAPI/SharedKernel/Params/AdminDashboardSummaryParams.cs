namespace SharedKernel.Params;

public class AdminDashboardSummaryParams
{
    public DateOnly StartDate { get; set; } = DateOnly.MinValue;
    public DateOnly EndDate { get; set; } = DateOnly.MaxValue;
}
