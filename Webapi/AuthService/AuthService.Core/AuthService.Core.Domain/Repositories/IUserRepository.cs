using AuthService.Core.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AuthService.Core.Domain.Repositories;

public interface IUserRepository
{
    Task<User?> GetUserByIdAsync(Guid id);
    Task<PagedList<UserDto>> GetUsersAsync(UserParams userParams);
    Task<bool> SaveChangesAsync();
}
