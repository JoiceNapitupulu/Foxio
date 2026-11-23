using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Foxio.API.Entities;
using Microsoft.IdentityModel.Tokens;

namespace Foxio.API.Services;

public interface ITokenService
{
    string GenerateToken(User user);
}

public class TokenService : ITokenService
{
    private readonly IConfiguration _config;

    public TokenService(IConfiguration config)
    {
        _config = config;
    }

    public string GenerateToken(User user)
    {
        var key = _config["Jwt:Key"] ?? "foxio_super_secret_jwt_key_2026_change_in_production!";
        var issuer = _config["Jwt:Issuer"] ?? "FoxioAPI";
        var audience = _config["Jwt:Audience"] ?? "FoxioClient";

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Email, user.Email),
            new(ClaimTypes.Name, user.DisplayName)
        };

        var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddDays(30), // 30 days session for mobile
            Issuer = issuer,
            Audience = audience,
            SigningCredentials = credentials
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }
}
