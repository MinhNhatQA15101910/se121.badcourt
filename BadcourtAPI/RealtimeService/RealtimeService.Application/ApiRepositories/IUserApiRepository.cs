using SharedKernel.DTOs;

namespace RealtimeService.Application.ApiRepositories;

public interface IUserApiRepository
{
    Task<UserDto?> GetUserByIdAsync(Guid userId);
}
