using AutoMapper;
using AutoMapper.QueryableExtensions;
using Domain.Entities;
using Domain.Repositories;
using Microsoft.EntityFrameworkCore;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace Persistence.Repositories;

public class UserRepository(DataContext context, IMapper mapper) : IUserRepository
{
    public async Task<User?> GetUserByIdAsync(Guid id)
    {
        return await context.Users
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .Include(u => u.Photos)
            .FirstOrDefaultAsync(u => u.Id == id);
    }

    public async Task<PagedList<UserDto>> GetUsersAsync(UserParams userParams)
    {
        var query = context.Users.AsQueryable();

        // Remove current user
        query = query.Where(u => u.Id != userParams.CurrentUserId);

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
}
