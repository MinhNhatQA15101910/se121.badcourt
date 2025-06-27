using AuthService.Core.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AuthService.Core.Domain.Repositories;

public interface IUserRepository
{
    Task<User?> GetUserByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<PagedList<UserDto>> GetUsersAsync(Guid userId, UserParams userParams,
        CancellationToken cancellationToken = default);
    Task<bool> SaveChangesAsync();
}
