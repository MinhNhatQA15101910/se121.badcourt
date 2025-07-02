using AuthService.Core.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AuthService.Core.Domain.Repositories;

public interface IUserRepository
{
    Task<int> GetTotalNewPlayersForAdminAsync(CancellationToken cancellationToken = default);
    Task<int> GetTotalManagersForAdminAsync(
        AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default);
    Task<int> GetTotalPlayersForAdminAsync(
        AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default);
    Task<User?> GetUserByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<PagedList<UserDto>> GetUsersAsync(Guid userId, UserParams userParams,
        CancellationToken cancellationToken = default);
    Task<bool> SaveChangesAsync(CancellationToken cancellationToken = default);
    Task<int> GetTotalNewManagersForAdminAsync(CancellationToken cancellationToken = default);
    Task<List<UserStatDto>> GetUserStatsForAdminAsync(
        AdminDashboardUserStatParams userStatParams, CancellationToken cancellationToken = default);
}
