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

    // Navigation property
    public Habit? Habit { get; set; }
}
