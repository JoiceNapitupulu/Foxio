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
public class TodosController : BaseApiController
{
    private readonly FoxioDbContext _context;
    private readonly IGamificationService _gamification;

    public TodosController(FoxioDbContext context, IGamificationService gamification)
    {
        _context = context;
        _gamification = gamification;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<TodoResponse>>> GetTodos()
    {
        var userId = GetUserId();
        var todos = await _context.Todos
            .Where(t => t.UserId == userId && !t.IsDeleted)
            .OrderBy(t => t.IsCompleted)
            .ThenBy(t => t.Deadline)
            .ThenByDescending(t => t.CreatedAt)
            .Select(t => new TodoResponse(
                t.Id,
                t.Title,
                t.Description,
                t.IsCompleted,
                t.Deadline,
                t.CreatedAt,
                t.UpdatedAt
            ))
            .ToListAsync();

        return Ok(todos);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<TodoResponse>> GetTodo(Guid id)
    {
        var userId = GetUserId();
        var todo = await _context.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId && !t.IsDeleted);

        if (todo == null) return NotFound(new { message = "Todo tidak ditemukan." });

        return Ok(new TodoResponse(
            todo.Id,
            todo.Title,
            todo.Description,
            todo.IsCompleted,
            todo.Deadline,
            todo.CreatedAt,
            todo.UpdatedAt
        ));
    }

    [HttpPost]
    public async Task<ActionResult<TodoResponse>> CreateTodo([FromBody] CreateTodoRequest request)
    {
        var userId = GetUserId();
        var todo = new Todo
        {
            UserId = userId,
            Title = request.Title.Trim(),
            Description = request.Description?.Trim(),
            Deadline = request.Deadline,
            IsCompleted = false,
            CreatedAt = DateTime.UtcNow
        };

        _context.Todos.Add(todo);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetTodo), new { id = todo.Id }, new TodoResponse(
            todo.Id,
            todo.Title,
            todo.Description,
            todo.IsCompleted,
            todo.Deadline,
            todo.CreatedAt,
            todo.UpdatedAt
        ));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<TodoResponse>> UpdateTodo(Guid id, [FromBody] UpdateTodoRequest request)
    {
        var userId = GetUserId();
        var todo = await _context.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId && !t.IsDeleted);

        if (todo == null) return NotFound(new { message = "Todo tidak ditemukan." });

        todo.Title = request.Title.Trim();
        todo.Description = request.Description?.Trim();
        todo.IsCompleted = request.IsCompleted;
        todo.Deadline = request.Deadline;
        todo.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new TodoResponse(
            todo.Id,
            todo.Title,
            todo.Description,
            todo.IsCompleted,
            todo.Deadline,
            todo.CreatedAt,
            todo.UpdatedAt
        ));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTodo(Guid id)
    {
        var userId = GetUserId();
        var todo = await _context.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId && !t.IsDeleted);

        if (todo == null) return NotFound(new { message = "Todo tidak ditemukan." });

        // Soft delete for sync integrity
        todo.IsDeleted = true;
        todo.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpPatch("{id}/complete")]
    public async Task<ActionResult<CompleteTodoResponse>> ToggleComplete(Guid id)
    {
        var userId = GetUserId();
        var todo = await _context.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId && !t.IsDeleted);

        if (todo == null) return NotFound(new { message = "Todo tidak ditemukan." });

        var user = await _context.Users.FindAsync(userId);
        if (user == null) return Unauthorized();

        todo.IsCompleted = !todo.IsCompleted;
        todo.UpdatedAt = DateTime.UtcNow;

        int pointsDelta = todo.IsCompleted ? GamificationService.PointsPerTodo : -GamificationService.PointsPerTodo;
        bool leveledUp = _gamification.AddPoints(user, pointsDelta);

        await _context.SaveChangesAsync();

        return Ok(new CompleteTodoResponse(
            todo.Id,
            todo.IsCompleted,
            pointsDelta,
            user.TotalPoints,
            user.Level,
            leveledUp
        ));
    }
}
