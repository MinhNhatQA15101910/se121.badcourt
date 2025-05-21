using SharedKernel.DTOs;

namespace RealtimeService.Presentation.ApiRepositories;

public interface IUserApiRepository
{
    Task<UserDto?> GetUserByIdAsync(Guid userId);
}
