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
    public Task<int> GetTotalManagersForAdminAsync(AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken)
    {
        var query = context.Users.AsQueryable();

        // Filter by date range
        var startDateTime = summaryParams.StartDate.ToDateTime(TimeOnly.MinValue);
        var endDateTime = summaryParams.EndDate.ToDateTime(TimeOnly.MaxValue);
        query = query.Where(o => o.CreatedAt >= startDateTime && o.CreatedAt <= endDateTime);

        // Filter by role
        query = query.Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Manager"));

        // Count the total managers
        return query.CountAsync(cancellationToken: cancellationToken);
    }

    public async Task<int> GetTotalPlayersForAdminAsync(AdminDashboardSummaryParams summaryParams, CancellationToken cancellationToken)
    {
        var query = context.Users.AsQueryable();

        // Filter by date range
        var startDateTime = summaryParams.StartDate.ToDateTime(TimeOnly.MinValue);
        var endDateTime = summaryParams.EndDate.ToDateTime(TimeOnly.MaxValue);
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

        // Filter by email
        if (userParams.Email != null)
        {
            query = query.Where(u => u.NormalizedEmail!.Contains(userParams.Email.ToUpper()));
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

    public async Task<bool> SaveChangesAsync()
    {
        return await context.SaveChangesAsync() > 0;
    }
}
