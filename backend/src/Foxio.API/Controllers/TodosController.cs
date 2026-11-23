using Foxio.API.Data;
using Foxio.API.DTOs;
using Foxio.API.Entities;
using Foxio.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Foxio.API.Controllers;

[Authorize]
[Route("api/todos")]
public class TodosController : BaseApiController
{
    private readonly FoxioDbContext _context;
    private readonly IGamificationService _gamification;

    public TodosController(FoxioDbContext context, IGamificationService gamification)
    {
        _context = context;
        _gamification = gamification;
    }

    private static TodoResponseDto MapToDto(Todo t) => new(
        t.Id,
        t.Title,
        t.Description,
        t.IsCompleted,
        t.PointsAwarded,
        t.Deadline,
        t.CreatedAt,
        t.UpdatedAt
    );

    [HttpGet]
    public async Task<ActionResult<IEnumerable<TodoResponseDto>>> GetTodos(
        [FromQuery] bool? isCompleted = null,
        [FromQuery] DateOnly? deadlineDate = null)
    {
        var userId = GetUserId();

        var query = _context.Todos
            .AsNoTracking()
            .Where(t => t.UserId == userId && !t.IsDeleted);

        if (isCompleted.HasValue)
        {
            query = query.Where(t => t.IsCompleted == isCompleted.Value);
        }

        if (deadlineDate.HasValue)
        {
            var startUtc = deadlineDate.Value.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
            var endUtc = startUtc.AddDays(1);
            query = query.Where(t => t.Deadline != null && t.Deadline >= startUtc && t.Deadline < endUtc);
        }

        var todos = await query
            .OrderBy(t => t.IsCompleted)
            .ThenBy(t => t.Deadline == null)
            .ThenBy(t => t.Deadline)
            .ThenByDescending(t => t.CreatedAt)
            .Select(t => new TodoResponseDto(
                t.Id,
                t.Title,
                t.Description,
                t.IsCompleted,
                t.PointsAwarded,
                t.Deadline,
                t.CreatedAt,
                t.UpdatedAt
            ))
            .ToListAsync();

        return Ok(todos);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<TodoResponseDto>> GetTodo(Guid id)
    {
        var userId = GetUserId();
        var todo = await _context.Todos
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId && !t.IsDeleted);

        if (todo == null)
        {
            return NotFound(new { message = "Todo tidak ditemukan." });
        }

        return Ok(MapToDto(todo));
    }

    [HttpPost]
    public async Task<ActionResult<TodoResponseDto>> CreateTodo([FromBody] CreateTodoRequestDto request)
    {
        var userId = GetUserId();
        var now = DateTime.UtcNow;

        var todoId = request.Id.HasValue && request.Id.Value != Guid.Empty
            ? request.Id.Value
            : Guid.NewGuid();

        var todo = new Todo
        {
            Id = todoId,
            UserId = userId,
            Title = request.Title.Trim(),
            Description = request.Description?.Trim(),
            Deadline = request.Deadline,
            IsCompleted = false,
            PointsAwarded = false,
            IsDeleted = false,
            CreatedAt = now,
            UpdatedAt = now
        };

        _context.Todos.Add(todo);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetTodo), new { id = todo.Id }, MapToDto(todo));
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<TodoResponseDto>> UpdateTodo(Guid id, [FromBody] UpdateTodoRequestDto request)
    {
        var userId = GetUserId();
        var todo = await _context.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId && !t.IsDeleted);

        if (todo == null)
        {
            return NotFound(new { message = "Todo tidak ditemukan." });
        }

        todo.Title = request.Title.Trim();
        todo.Description = request.Description?.Trim();
        todo.Deadline = request.Deadline;
        todo.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(MapToDto(todo));
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteTodo(Guid id)
    {
        var userId = GetUserId();
        var todo = await _context.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId && !t.IsDeleted);

        if (todo == null)
        {
            return NotFound(new { message = "Todo tidak ditemukan." });
        }

        // Soft delete for offline-first sync integrity
        todo.IsDeleted = true;
        todo.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpPatch("{id:guid}/complete")]
    public async Task<ActionResult<CompleteTodoResponseDto>> CompleteTodo(
        Guid id,
        [FromBody(EmptyBodyBehavior = Microsoft.AspNetCore.Mvc.ModelBinding.EmptyBodyBehavior.Allow)] CompleteTodoRequestDto? request = null)
    {
        var userId = GetUserId();
        var todo = await _context.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId && !t.IsDeleted);

        if (todo == null)
        {
            return NotFound(new { message = "Todo tidak ditemukan." });
        }

        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return Unauthorized();
        }

        bool targetCompleted = request?.IsCompleted ?? !todo.IsCompleted;
        todo.IsCompleted = targetCompleted;
        todo.UpdatedAt = DateTime.UtcNow;

        int pointsEarned = 0;
        bool leveledUp = false;

        // Anti-duplicate points guard: only award +10 once per todo
        if (targetCompleted && !todo.PointsAwarded)
        {
            todo.PointsAwarded = true;
            pointsEarned = GamificationService.TodoCompletionPoints;
            leveledUp = _gamification.AddPoints(user, pointsEarned);
        }

        await _context.SaveChangesAsync();

        return Ok(new CompleteTodoResponseDto(
            MapToDto(todo),
            pointsEarned,
            user.TotalPoints,
            user.Level,
            leveledUp
        ));
    }
}
