namespace SharedKernel.DTOs;

public class AdminDashboardSummaryDto
{
    public decimal TotalRevenue { get; set; }
    public int TotalPlayers { get; set; }
    public int TotalManagers { get; set; }
    public int NewPlayers { get; set; }
    public int NewManagers { get; set; }
    public int TotalBookings { get; set; }
}
