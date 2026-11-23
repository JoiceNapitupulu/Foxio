using System.Security.Claims;
using Foxio.API.Data;
using Foxio.API.DTOs;
using Foxio.API.Entities;
using Foxio.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Foxio.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly FoxioDbContext _context;
    private readonly ITokenService _tokenService;

    public AuthController(FoxioDbContext context, ITokenService tokenService)
    {
        _context = context;
        _tokenService = tokenService;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        var emailNormalized = request.Email.Trim().ToLowerInvariant();

        if (await _context.Users.AnyAsync(u => u.Email == emailNormalized))
        {
            return BadRequest(new { message = "Email sudah terdaftar." });
        }

        var user = new User
        {
            Email = emailNormalized,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            DisplayName = request.DisplayName.Trim(),
            Level = 1,
            TotalPoints = 0,
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var token = _tokenService.GenerateToken(user);

        return Ok(new AuthResponse(
            user.Id,
            user.Email,
            user.DisplayName,
            user.Level,
            user.TotalPoints,
            token
        ));
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
    {
        var emailNormalized = request.Email.Trim().ToLowerInvariant();
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == emailNormalized);

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new { message = "Email atau password salah." });
        }

        var token = _tokenService.GenerateToken(user);

        return Ok(new AuthResponse(
            user.Id,
            user.Email,
            user.DisplayName,
            user.Level,
            user.TotalPoints,
            token
        ));
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<ActionResult<UserProfileResponse>> GetCurrentUser()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
        {
            return Unauthorized();
        }

        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return NotFound(new { message = "User tidak ditemukan." });
        }

        return Ok(new UserProfileResponse(
            user.Id,
            user.Email,
            user.DisplayName,
            user.Level,
            user.TotalPoints,
            user.CreatedAt
        ));
    }
}
