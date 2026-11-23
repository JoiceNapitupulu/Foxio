using Foxio.API.Data;
using Foxio.API.DTOs;
using Foxio.API.Entities;
using Foxio.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Foxio.API.Controllers;

[Authorize]
[Route("api/[controller]")]
public class HabitsController : BaseApiController
{
    private readonly FoxioDbContext _context;
    private readonly IGamificationService _gamification;

    public HabitsController(FoxioDbContext context, IGamificationService gamification)
    {
        _context = context;
        _gamification = gamification;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<HabitResponse>>> GetHabits()
    {
        var userId = GetUserId();
        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        var habits = await _context.Habits
            .Where(h => h.UserId == userId && !h.IsDeleted)
            .OrderByDescending(h => h.CreatedAt)
            .Select(h => new HabitResponse(
                h.Id,
                h.Title,
                h.Frequency,
                h.CurrentStreak,
                h.LongestStreak,
                h.Logs.Any(l => l.Date == today && l.IsCompleted),
                h.CreatedAt
            ))
            .ToListAsync();

        return Ok(habits);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<HabitResponse>> GetHabit(Guid id)
    {
        var userId = GetUserId();
        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        var habit = await _context.Habits
            .Include(h => h.Logs)
            .FirstOrDefaultAsync(h => h.Id == id && h.UserId == userId && !h.IsDeleted);

        if (habit == null) return NotFound(new { message = "Habit tidak ditemukan." });

        return Ok(new HabitResponse(
            habit.Id,
            habit.Title,
            habit.Frequency,
            habit.CurrentStreak,
            habit.LongestStreak,
            habit.Logs.Any(l => l.Date == today && l.IsCompleted),
            habit.CreatedAt
        ));
    }

    [HttpPost]
    public async Task<ActionResult<HabitResponse>> CreateHabit([FromBody] CreateHabitRequest request)
    {
        var userId = GetUserId();
        var habit = new Habit
        {
            UserId = userId,
            Title = request.Title.Trim(),
            Frequency = request.Frequency.Trim(),
            CurrentStreak = 0,
            LongestStreak = 0,
            CreatedAt = DateTime.UtcNow
        };

        _context.Habits.Add(habit);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetHabit), new { id = habit.Id }, new HabitResponse(
            habit.Id,
            habit.Title,
            habit.Frequency,
            habit.CurrentStreak,
            habit.LongestStreak,
            false,
            habit.CreatedAt
        ));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<HabitResponse>> UpdateHabit(Guid id, [FromBody] UpdateHabitRequest request)
    {
        var userId = GetUserId();
        var habit = await _context.Habits
            .Include(h => h.Logs)
            .FirstOrDefaultAsync(h => h.Id == id && h.UserId == userId && !h.IsDeleted);

        if (habit == null) return NotFound(new { message = "Habit tidak ditemukan." });

        habit.Title = request.Title.Trim();
        habit.Frequency = request.Frequency.Trim();
        habit.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        return Ok(new HabitResponse(
            habit.Id,
            habit.Title,
            habit.Frequency,
            habit.CurrentStreak,
            habit.LongestStreak,
            habit.Logs.Any(l => l.Date == today && l.IsCompleted),
            habit.CreatedAt
        ));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteHabit(Guid id)
    {
        var userId = GetUserId();
        var habit = await _context.Habits
            .FirstOrDefaultAsync(h => h.Id == id && h.UserId == userId && !h.IsDeleted);

        if (habit == null) return NotFound(new { message = "Habit tidak ditemukan." });

        habit.IsDeleted = true;
        habit.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id}/log")]
    public async Task<ActionResult<LogHabitResponse>> LogHabitToday(Guid id)
    {
        var userId = GetUserId();
        var habit = await _context.Habits
            .Include(h => h.Logs)
            .FirstOrDefaultAsync(h => h.Id == id && h.UserId == userId && !h.IsDeleted);

        if (habit == null) return NotFound(new { message = "Habit tidak ditemukan." });

        var user = await _context.Users.FindAsync(userId);
        if (user == null) return Unauthorized();

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var yesterday = today.AddDays(-1);

        var existingTodayLog = habit.Logs.FirstOrDefault(l => l.Date == today);
        bool isNowCompleted;
        int pointsDelta;

        if (existingTodayLog == null)
        {
            // Belum dicentang hari ini -> Jadikan selesai (Centang)
            var newLog = new HabitLog
            {
                HabitId = habit.Id,
                Date = today,
                IsCompleted = true,
                LoggedAt = DateTime.UtcNow
            };
            _context.HabitLogs.Add(newLog);

            // Hitung streak
            bool yesterdayCompleted = habit.Logs.Any(l => l.Date == yesterday && l.IsCompleted);
            habit.CurrentStreak = yesterdayCompleted ? habit.CurrentStreak + 1 : 1;
            if (habit.CurrentStreak > habit.LongestStreak)
            {
                habit.LongestStreak = habit.CurrentStreak;
            }

            pointsDelta = GamificationService.PointsPerHabit;
            isNowCompleted = true;
        }
        else
        {
            // Sudah dicentang hari ini -> Batalkan centang (Uncheck)
            _context.HabitLogs.Remove(existingTodayLog);

            // Revert streak
            habit.CurrentStreak = Math.Max(0, habit.CurrentStreak - 1);
            pointsDelta = -GamificationService.PointsPerHabit;
            isNowCompleted = false;
        }

        habit.UpdatedAt = DateTime.UtcNow;
        bool leveledUp = _gamification.AddPoints(user, pointsDelta);

        await _context.SaveChangesAsync();

        return Ok(new LogHabitResponse(
            habit.Id,
            today,
            isNowCompleted,
            habit.CurrentStreak,
            habit.LongestStreak,
            pointsDelta,
            user.TotalPoints,
            user.Level,
            leveledUp
        ));
    }
}
