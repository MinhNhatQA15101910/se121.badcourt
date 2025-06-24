using SharedKernel.DTOs;

namespace FacilityService.Core.Application.ExternalServices.Interfaces;

public interface IUserServiceClient
{
    Task<UserDto?> GetUserByIdAsync(Guid userId);
}
