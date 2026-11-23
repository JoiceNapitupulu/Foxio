using System.ComponentModel.DataAnnotations;

namespace Foxio.API.DTOs;

public record CreateHabitRequest(
    [Required][MaxLength(150)] string Title,
    [Required] string Frequency // "Daily" or "Weekly"
);

public record UpdateHabitRequest(
    [Required][MaxLength(150)] string Title,
    [Required] string Frequency
);

public record HabitResponse(
    Guid Id,
    string Title,
    string Frequency,
    int CurrentStreak,
    int LongestStreak,
    bool IsCompletedToday,
    DateTime CreatedAt
);

public record LogHabitResponse(
    Guid HabitId,
    DateOnly Date,
    bool IsCompleted,
    int CurrentStreak,
    int LongestStreak,
    int PointsEarned,
    int TotalPoints,
    int Level,
    bool LeveledUp
);
