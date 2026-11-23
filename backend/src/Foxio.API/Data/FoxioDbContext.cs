using Foxio.API.Entities;
using Microsoft.EntityFrameworkCore;

namespace Foxio.API.Data;

public class FoxioDbContext : DbContext
{
    public FoxioDbContext(DbContextOptions<FoxioDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Todo> Todos => Set<Todo>();
    public DbSet<Habit> Habits => Set<Habit>();
    public DbSet<HabitLog> HabitLogs => Set<HabitLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Email).IsUnique();
        });

        // Todo configuration (composite index for fast user queries & offline sync)
        modelBuilder.Entity<Todo>(entity =>
        {
            entity.HasIndex(t => new { t.UserId, t.IsDeleted, t.UpdatedAt });
            entity.HasOne(t => t.User)
                  .WithMany(u => u.Todos)
                  .HasForeignKey(t => t.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Habit configuration (composite index for fast user queries & offline sync)
        modelBuilder.Entity<Habit>(entity =>
        {
            entity.HasIndex(h => new { h.UserId, h.IsDeleted, h.UpdatedAt });
            entity.HasOne(h => h.User)
                  .WithMany(u => u.Habits)
                  .HasForeignKey(h => h.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // HabitLog configuration (unique per Habit + Local DateOnly)
        modelBuilder.Entity<HabitLog>(entity =>
        {
            entity.HasIndex(hl => new { hl.HabitId, hl.Date }).IsUnique();
            entity.HasOne(hl => hl.Habit)
                  .WithMany(h => h.Logs)
                  .HasForeignKey(hl => hl.HabitId)
                  .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
