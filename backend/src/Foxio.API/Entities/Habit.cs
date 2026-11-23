using System.ComponentModel.DataAnnotations;

namespace Foxio.API.Entities;

public class Habit
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid UserId { get; set; }

    [Required]
    [MaxLength(150)]
    public string Title { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    public string Frequency { get; set; } = "Daily"; // "Daily" or "Weekly"

    public int CurrentStreak { get; set; } = 0;
    public int LongestStreak { get; set; } = 0;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public bool IsDeleted { get; set; } = false;

    // Navigation properties
    public User? User { get; set; }
    public ICollection<HabitLog> Logs { get; set; } = new List<HabitLog>();
}
