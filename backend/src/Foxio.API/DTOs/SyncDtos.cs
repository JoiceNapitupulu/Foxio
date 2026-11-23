namespace Foxio.API.DTOs;

public record TodoSyncItem(
    Guid Id,
    string Title,
    string? Description,
    bool IsCompleted,
    DateTime? Deadline,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    bool IsDeleted
);

public record HabitSyncItem(
    Guid Id,
    string Title,
    string Frequency,
    int CurrentStreak,
    int LongestStreak,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    bool IsDeleted
);

public record HabitLogSyncItem(
    Guid HabitId,
    DateOnly Date,
    bool IsCompleted,
    DateTime LoggedAt
);

public record SyncPushRequest(
    DateTime? LastSyncedAt,
    List<TodoSyncItem>? Todos,
    List<HabitSyncItem>? Habits,
    List<HabitLogSyncItem>? HabitLogs
);

public record SyncPullResponse(
    List<TodoSyncItem> Todos,
    List<HabitSyncItem> Habits,
    List<HabitLogSyncItem> HabitLogs,
    int TotalPoints,
    int Level,
    DateTime ServerTimestamp
);
