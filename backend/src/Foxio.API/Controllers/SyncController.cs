using Foxio.API.Data;
using Foxio.API.DTOs;
using Foxio.API.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Foxio.API.Controllers;

[Authorize]
[Route("api/[controller]")]
public class SyncController : BaseApiController
{
    private readonly FoxioDbContext _context;

    public SyncController(FoxioDbContext context)
    {
        _context = context;
    }

    [HttpPost]
    public async Task<ActionResult<SyncPullResponse>> SyncBatch([FromBody] SyncPushRequest request)
    {
        var userId = GetUserId();
        var user = await _context.Users.FindAsync(userId);
        if (user == null) return Unauthorized();

        var now = DateTime.UtcNow;

        // 1. Process client Todos push (Last-Write-Wins)
        if (request.Todos != null && request.Todos.Count > 0)
        {
            foreach (var clientTodo in request.Todos)
            {
                var existing = await _context.Todos.FirstOrDefaultAsync(t => t.Id == clientTodo.Id && t.UserId == userId);
                if (existing == null)
                {
                    _context.Todos.Add(new Todo
                    {
                        Id = clientTodo.Id,
                        UserId = userId,
                        Title = clientTodo.Title,
                        Description = clientTodo.Description,
                        IsCompleted = clientTodo.IsCompleted,
                        Deadline = clientTodo.Deadline,
                        CreatedAt = clientTodo.CreatedAt,
                        UpdatedAt = clientTodo.UpdatedAt ?? now,
                        IsDeleted = clientTodo.IsDeleted
                    });
                }
                else
                {
                    var clientUpdate = clientTodo.UpdatedAt ?? clientTodo.CreatedAt;
                    var serverUpdate = existing.UpdatedAt;
                    if (clientUpdate >= serverUpdate)
                    {
                        existing.Title = clientTodo.Title;
                        existing.Description = clientTodo.Description;
                        existing.IsCompleted = clientTodo.IsCompleted;
                        existing.Deadline = clientTodo.Deadline;
                        existing.IsDeleted = clientTodo.IsDeleted;
                        existing.UpdatedAt = clientUpdate;
                    }
                }
            }
        }

        // 2. Process client Habits push
        if (request.Habits != null && request.Habits.Count > 0)
        {
            foreach (var clientHabit in request.Habits)
            {
                var existing = await _context.Habits.FirstOrDefaultAsync(h => h.Id == clientHabit.Id && h.UserId == userId);
                if (existing == null)
                {
                    _context.Habits.Add(new Habit
                    {
                        Id = clientHabit.Id,
                        UserId = userId,
                        Title = clientHabit.Title,
                        Frequency = clientHabit.Frequency,
                        CurrentStreak = clientHabit.CurrentStreak,
                        LongestStreak = clientHabit.LongestStreak,
                        CreatedAt = clientHabit.CreatedAt,
                        UpdatedAt = clientHabit.UpdatedAt ?? now,
                        IsDeleted = clientHabit.IsDeleted
                    });
                }
                else
                {
                    var clientUpdate = clientHabit.UpdatedAt ?? clientHabit.CreatedAt;
                    var serverUpdate = existing.UpdatedAt;
                    if (clientUpdate >= serverUpdate)
                    {
                        existing.Title = clientHabit.Title;
                        existing.Frequency = clientHabit.Frequency;
                        existing.CurrentStreak = clientHabit.CurrentStreak;
                        existing.LongestStreak = clientHabit.LongestStreak;
                        existing.IsDeleted = clientHabit.IsDeleted;
                        existing.UpdatedAt = clientUpdate;
                    }
                }
            }
        }

        // 3. Process Habit Logs
        if (request.HabitLogs != null && request.HabitLogs.Count > 0)
        {
            foreach (var clientLog in request.HabitLogs)
            {
                var existing = await _context.HabitLogs
                    .FirstOrDefaultAsync(hl => hl.HabitId == clientLog.HabitId && hl.Date == clientLog.Date);

                if (existing == null)
                {
                    _context.HabitLogs.Add(new HabitLog
                    {
                        HabitId = clientLog.HabitId,
                        Date = clientLog.Date,
                        IsCompleted = clientLog.IsCompleted,
                        LoggedAt = clientLog.LoggedAt
                    });
                }
                else
                {
                    existing.IsCompleted = clientLog.IsCompleted;
                    existing.LoggedAt = clientLog.LoggedAt;
                }
            }
        }

        await _context.SaveChangesAsync();

        // 4. Pull changes for client since LastSyncedAt
        var lastSync = request.LastSyncedAt ?? DateTime.MinValue;

        var serverTodos = await _context.Todos
            .Where(t => t.UserId == userId && t.UpdatedAt > lastSync)
            .Select(t => new TodoSyncItem(
                t.Id,
                t.Title,
                t.Description,
                t.IsCompleted,
                t.Deadline,
                t.CreatedAt,
                t.UpdatedAt,
                t.IsDeleted
            ))
            .ToListAsync();

        var serverHabits = await _context.Habits
            .Where(h => h.UserId == userId && h.UpdatedAt > lastSync)
            .Select(h => new HabitSyncItem(
                h.Id,
                h.Title,
                h.Frequency,
                h.CurrentStreak,
                h.LongestStreak,
                h.CreatedAt,
                h.UpdatedAt,
                h.IsDeleted
            ))
            .ToListAsync();

        var userHabitIds = await _context.Habits
            .Where(h => h.UserId == userId)
            .Select(h => h.Id)
            .ToListAsync();

        var serverHabitLogs = await _context.HabitLogs
            .Where(hl => userHabitIds.Contains(hl.HabitId) && hl.LoggedAt > lastSync)
            .Select(hl => new HabitLogSyncItem(
                hl.HabitId,
                hl.Date,
                hl.IsCompleted,
                hl.LoggedAt
            ))
            .ToListAsync();

        return Ok(new SyncPullResponse(
            serverTodos,
            serverHabits,
            serverHabitLogs,
            user.TotalPoints,
            user.Level,
            now
        ));
    }
}
