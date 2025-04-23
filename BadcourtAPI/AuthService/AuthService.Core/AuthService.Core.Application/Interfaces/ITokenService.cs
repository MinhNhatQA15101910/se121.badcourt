using AuthService.Core.Domain.Entities;

namespace AuthService.Core.Application.Interfaces;

public interface ITokenService
{
    Task<string> CreateTokenAsync(User user);
    string CreateVerifyPincodeToken(string email, string action);
}
