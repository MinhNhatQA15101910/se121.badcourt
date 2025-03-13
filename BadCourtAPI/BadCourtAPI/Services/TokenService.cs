using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BadCourtAPI.Entities;
using BadCourtAPI.Interfaces.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;

namespace BadCourtAPI.Services;

public class TokenService(
    IConfiguration config,
    UserManager<User> userManager
) : ITokenService
{
    public async Task<string> CreateTokenAsync(User user)
    {
        var tokenKey = config["TokenKey"] ?? throw new Exception("Cannot access TokenKey from appsettings");
        if (tokenKey.Length < 64)
        {
            throw new Exception("You tokenKey needs to be at least 64 characters long");
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenKey));

        if (user.Email == null)
        {
            throw new Exception("User email is required to create a token");
        }

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Email, user.Email)
        };

        var roles = await userManager.GetRolesAsync(user);

        claims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.Now.AddDays(7),
            SigningCredentials = creds
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);

        return tokenHandler.WriteToken(token);
    }
}
