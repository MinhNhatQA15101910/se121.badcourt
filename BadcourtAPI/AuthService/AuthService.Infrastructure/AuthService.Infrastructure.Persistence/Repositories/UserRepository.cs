using AuthService.Core.Domain.Entities;
using AuthService.Core.Domain.Repositories;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AuthService.Infrastructure.Persistence.Repositories;

public class UserRepository(DataContext context, IMapper mapper) : IUserRepository
{
    public Task<int> GetTotalNewPlayersForAdminAsync(CancellationToken cancellationToken = default)
    {
        var query = context.Users.AsQueryable();

        // Filter by role
        query = query.Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Player"));

        // Count the new players created in the last 30 days
        var startDate = DateTime.UtcNow.AddDays(-30);
        query = query.Where(u => u.CreatedAt >= startDate);

        return query.CountAsync(cancellationToken: cancellationToken);
    }

    public Task<int> GetTotalManagersForAdminAsync(AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default)
    {
        var query = context.Users.AsQueryable();

        // Filter by date range
        var startDateTime = DateTime.SpecifyKind(summaryParams.StartDate.ToDateTime(TimeOnly.MinValue), DateTimeKind.Utc);
        var endDateTime = DateTime.SpecifyKind(summaryParams.EndDate.ToDateTime(TimeOnly.MaxValue), DateTimeKind.Utc);
        query = query.Where(o => o.CreatedAt >= startDateTime && o.CreatedAt <= endDateTime);

        // Filter by role
        query = query.Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Manager"));

        // Count the total managers
        return query.CountAsync(cancellationToken: cancellationToken);
    }

    public async Task<int> GetTotalPlayersForAdminAsync(AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken = default)
    {
        var query = context.Users.AsQueryable();

        // Filter by date range
        var startDateTime = DateTime.SpecifyKind(summaryParams.StartDate.ToDateTime(TimeOnly.MinValue), DateTimeKind.Utc);
        var endDateTime = DateTime.SpecifyKind(summaryParams.EndDate.ToDateTime(TimeOnly.MaxValue), DateTimeKind.Utc);
        query = query.Where(o => o.CreatedAt >= startDateTime && o.CreatedAt <= endDateTime);

        // Filter by role
        query = query.Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Player"));

        // Count the total players
        return await query.CountAsync(cancellationToken: cancellationToken);
    }

    public async Task<User?> GetUserByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await context.Users
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .Include(u => u.Photos)
            .FirstOrDefaultAsync(u => u.Id == id, cancellationToken: cancellationToken);
    }

    public async Task<PagedList<UserDto>> GetUsersAsync(Guid userId, UserParams userParams,
        CancellationToken cancellationToken = default)
    {
        var query = context.Users.AsQueryable();

        // Remove current user
        query = query.Where(u => u.Id != userId);

        // Filter by username
        if (userParams.Search != null)
        {
            query = query.Where(u => u.UserName!.ToLower().Contains(userParams.Search.ToLower())
                        || u.NormalizedEmail!.Contains(userParams.Search.ToUpper()));
        }

        // Filter by role
        if (userParams.Role != null)
        {
            query = query.Where(u => u.UserRoles.Any(ur => ur.Role.Name!.ToLower() == userParams.Role.ToLower()));
        }

        // Order
        query = userParams.OrderBy switch
        {
            "email" => userParams.SortBy == "asc"
                        ? query.OrderBy(u => u.Email)
                        : query.OrderByDescending(u => u.Email),
            "updatedAt" => userParams.SortBy == "asc"
                        ? query.OrderBy(u => u.UpdatedAt)
                        : query.OrderByDescending(u => u.UpdatedAt),
            _ => query.OrderBy(u => u.Email)
        };

        return await PagedList<UserDto>.CreateAsync(
            query.ProjectTo<UserDto>(mapper.ConfigurationProvider),
            userParams.PageNumber,
            userParams.PageSize
        );
    }

    public async Task<bool> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await context.SaveChangesAsync(cancellationToken) > 0;
    }

    public Task<int> GetTotalNewManagersForAdminAsync(CancellationToken cancellationToken = default)
    {
        var query = context.Users.AsQueryable();

        // Filter by role
        query = query.Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Manager"));

        // Count the new managers created in the last 30 days
        var startDate = DateTime.UtcNow.AddDays(-30);
        query = query.Where(u => u.CreatedAt >= startDate);

        return query.CountAsync(cancellationToken: cancellationToken);
    }

    public async Task<List<UserStatDto>> GetUserStatsForAdminAsync(AdminDashboardUserStatParams userStatParams, CancellationToken cancellationToken = default)
    {
        var year = userStatParams.Year;

        var usersInYear = await context.Users
            .Where(u => u.CreatedAt.Year == year)
            .Select(u => new
            {
                u.CreatedAt.Month,
                Roles = u.UserRoles.Select(ur => ur.Role.Name)
            })
            .ToListAsync(cancellationToken);

        var stats = Enumerable.Range(1, 12).Select(month => new UserStatDto
        {
            Month = month,
            Players = 0,
            Managers = 0
        }).ToList();

        foreach (var user in usersInYear)
        {
            var stat = stats.First(s => s.Month == user.Month);
            if (user.Roles.Contains("Player"))
                stat.Players++;
            if (user.Roles.Contains("Manager"))
                stat.Managers++;
        }

        return stats;
    }

    public Task<User?> GetAdminAsync(CancellationToken cancellationToken = default)
    {
        return context.Users
            .Include(u => u.Photos)
            .FirstOrDefaultAsync(u => u.UserRoles.Any(ur => ur.Role.Name == "Admin"), cancellationToken: cancellationToken);
    }
}
