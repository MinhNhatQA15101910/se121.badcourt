using BadCourtAPI.Entities;

namespace BadCourtAPI.Interfaces.Services;

public interface ITokenService
{
    Task<string> CreateTokenAsync(User user);
}
