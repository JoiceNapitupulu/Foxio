using System.ComponentModel.DataAnnotations;

namespace Foxio.API.Entities;

public class HabitLog
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid HabitId { get; set; }

    [Required]
    public DateOnly Date { get; set; }

    public bool IsCompleted { get; set; } = true;
    public DateTime LoggedAt { get; set; } = DateTime.UtcNow;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public bool IsDeleted { get; set; } = false;

    // Navigation property
    public Habit? Habit { get; set; }
}
