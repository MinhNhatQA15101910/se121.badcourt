using SharedKernel.DTOs;

namespace PostService.Application.ApiRepositories;

public interface IUserApiRepository
{
    Task<UserDto?> GetUserByIdAsync(Guid userId);
}
