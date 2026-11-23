using System.ComponentModel.DataAnnotations;

namespace Foxio.API.Entities;

public class User
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [EmailAddress]
    [MaxLength(150)]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string PasswordHash { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string DisplayName { get; set; } = string.Empty;

    public int Level { get; set; } = 1;
    public int TotalPoints { get; set; } = 0;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public ICollection<Todo> Todos { get; set; } = new List<Todo>();
    public ICollection<Habit> Habits { get; set; } = new List<Habit>();
}
