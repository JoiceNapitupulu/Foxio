using Foxio.API.Data;
using Foxio.API.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Foxio.API.Controllers;

[Authorize]
[Route("api/[controller]")]
public class StatsController : BaseApiController
{
    private readonly FoxioDbContext _context;

    public StatsController(FoxioDbContext context)
    {
        _context = context;
    }

    [HttpGet("overview")]
    public async Task<ActionResult<StatsOverviewResponse>> GetOverview()
    {
        var userId = GetUserId();
        var user = await _context.Users.FindAsync(userId);
        if (user == null) return Unauthorized();

        var todos = await _context.Todos
            .Where(t => t.UserId == userId && !t.IsDeleted)
            .ToListAsync();

        var habits = await _context.Habits
            .Where(h => h.UserId == userId && !h.IsDeleted)
            .ToListAsync();

        var totalTodos = todos.Count;
        var completedTodos = todos.Count(t => t.IsCompleted);
        var completionRate = totalTodos > 0 ? Math.Round((double)completedTodos / totalTodos * 100, 1) : 0.0;

        var totalHabits = habits.Count;
        var activeStreaks = habits.Count(h => h.CurrentStreak > 0);
        var longestStreak = habits.Count > 0 ? habits.Max(h => h.LongestStreak) : 0;

        return Ok(new StatsOverviewResponse(
            totalTodos,
            completedTodos,
            completionRate,
            totalHabits,
            activeStreaks,
            longestStreak,
            user.Level,
            user.TotalPoints
        ));
    }

    [HttpGet("weekly")]
    public async Task<ActionResult<WeeklyStatsResponse>> GetWeeklyStats()
    {
        var userId = GetUserId();
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var sevenDaysAgo = today.AddDays(-6);

        // Ambil logs habit 7 hari terakhir
        var habitLogs = await _context.HabitLogs
            .Include(hl => hl.Habit)
            .Where(hl => hl.Habit != null && hl.Habit.UserId == userId && hl.Date >= sevenDaysAgo && hl.Date <= today && hl.IsCompleted)
            .ToListAsync();

        // Ambil todo yang selesai dalam rentang waktu yang sama
        var minDateUtc = sevenDaysAgo.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
        var completedTodos = await _context.Todos
            .Where(t => t.UserId == userId && !t.IsDeleted && t.IsCompleted && t.UpdatedAt >= minDateUtc)
            .ToListAsync();

        var dailyStats = new List<DailyStat>();
        int totalCompleted = 0;

        for (int i = 0; i < 7; i++)
        {
            var date = sevenDaysAgo.AddDays(i);
            var habitsCount = habitLogs.Count(hl => hl.Date == date);
            var todosCount = completedTodos.Count(t => t.UpdatedAt.HasValue && DateOnly.FromDateTime(t.UpdatedAt.Value) == date);

            dailyStats.Add(new DailyStat(date, todosCount, habitsCount));
            totalCompleted += (habitsCount + todosCount);
        }

        return Ok(new WeeklyStatsResponse(dailyStats, totalCompleted));
    }
}
