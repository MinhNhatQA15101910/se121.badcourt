using Domain.Entities;

namespace Application.Interfaces;

public interface ITokenService
{
    Task<string> CreateTokenAsync(User user);
    string CreateVerifyPincodeToken(string email, string action);
}
