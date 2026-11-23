namespace Foxio.API.DTOs;

public record StatsOverviewResponse(
    int TotalTodos,
    int CompletedTodos,
    double CompletionRate,
    int TotalHabits,
    int ActiveStreaks,
    int LongestStreak,
    int Level,
    int TotalPoints
);

public record DailyStat(
    DateOnly Date,
    int TodosCompleted,
    int HabitsCompleted
);

public record WeeklyStatsResponse(
    List<DailyStat> Days,
    int TotalCompletedThisWeek
);
