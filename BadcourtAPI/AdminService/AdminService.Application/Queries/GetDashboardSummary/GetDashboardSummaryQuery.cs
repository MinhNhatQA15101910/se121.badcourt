using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AdminService.Application.Queries.GetDashboardSummary;

public record GetDashboardSummaryQuery(
    AdminDashboardSummaryParams Params
) : IQuery<AdminDashboardSummaryDto>;
