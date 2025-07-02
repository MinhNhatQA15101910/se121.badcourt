namespace SharedKernel.Params;

public class ManagerDashboardCourtRevenueParams
{
    public required string FacilityId { get; set; }
    public required int Year { get; set; }
    public int? Month { get; set; }
}
