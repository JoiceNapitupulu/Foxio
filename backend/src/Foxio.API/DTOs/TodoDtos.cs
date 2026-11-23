using System.ComponentModel.DataAnnotations;

namespace Foxio.API.DTOs;

public record CreateTodoRequestDto(
    Guid? Id,
    [Required][MaxLength(200)] string Title,
    [MaxLength(1000)] string? Description,
    DateTime? Deadline
);

public record UpdateTodoRequestDto(
    [Required][MaxLength(200)] string Title,
    [MaxLength(1000)] string? Description,
    DateTime? Deadline
);

public record CompleteTodoRequestDto(
    bool? IsCompleted
);

public record TodoResponseDto(
    Guid Id,
    string Title,
    string? Description,
    bool IsCompleted,
    bool PointsAwarded,
    DateTime? Deadline,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public record CompleteTodoResponseDto(
    TodoResponseDto Todo,
    int PointsEarned,
    int TotalPoints,
    int Level,
    bool LeveledUp
);
