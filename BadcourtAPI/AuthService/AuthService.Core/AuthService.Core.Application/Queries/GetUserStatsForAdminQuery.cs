using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AuthService.Core.Application.Queries;

public record GetUserStatsForAdminQuery(
    AdminDashboardUserStatParams UserStatParams
) : IQuery<List<UserStatDto>>;
