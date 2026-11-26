using System.ComponentModel.DataAnnotations;

namespace Foxio.API.DTOs;

public record RegisterRequest(
    [Required][EmailAddress] string Email,
    [Required][MinLength(6)] string Password,
    [Required][MaxLength(100)] string DisplayName
);

public record LoginRequest(
    [Required][EmailAddress] string Email,
    [Required] string Password
);

public record AuthResponse(
    Guid Id,
    string Email,
    string DisplayName,
    int Level,
    int TotalPoints,
    string Token,
    string? AvatarData = null
);

public record UserProfileResponse(
    Guid Id,
    string Email,
    string DisplayName,
    int Level,
    int TotalPoints,
    DateTime CreatedAt,
    string? AvatarData = null
);

public record UpdateProfileRequest(
    [MaxLength(100)] string? DisplayName,
    string? AvatarData,
    bool ClearAvatar = false
);
