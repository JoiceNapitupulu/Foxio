using System.ComponentModel.DataAnnotations;

namespace Foxio.API.DTOs;

public record CreateTodoRequest(
    [Required][MaxLength(200)] string Title,
    string? Description,
    DateTime? Deadline
);

public record UpdateTodoRequest(
    [Required][MaxLength(200)] string Title,
    string? Description,
    bool IsCompleted,
    DateTime? Deadline
);

public record TodoResponse(
    Guid Id,
    string Title,
    string? Description,
    bool IsCompleted,
    DateTime? Deadline,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);

public record CompleteTodoResponse(
    Guid Id,
    bool IsCompleted,
    int PointsEarned,
    int TotalPoints,
    int Level,
    bool LeveledUp
);
