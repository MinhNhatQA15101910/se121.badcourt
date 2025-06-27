namespace ManagerService.Application.Queries.GetDashboardSummary;

public class DashboardSummaryResponse
{
    public decimal TotalRevenue { get; set; }
    public int TotalOrders { get; set; }
    public int TotalCustomers { get; set; }
    public int TotalFacilities { get; set; }
}
