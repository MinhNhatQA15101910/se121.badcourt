using SharedKernel.DTOs;

namespace OrderService.Core.Application.ApiRepository;

public interface IUserApiRepository
{
    Task<UserDto?> GetUserByIdAsync(string userId, CancellationToken cancellationToken = default);
}
