using Foxio.API.Entities;

namespace Foxio.API.Services;

public interface IGamificationService
{
    int CalculateLevel(int totalPoints);
    int GetMaxPointsForLevel(int level);
    int GetPointsToNextLevel(int totalPoints);
    bool AddPoints(User user, int points);
}

public class GamificationService : IGamificationService
{
    public const int TodoCompletionPoints = 10;
    public const int HabitCompletionPoints = 15;

    // Backwards-compatible aliases
    public const int PointsPerTodo = TodoCompletionPoints;
    public const int PointsPerHabit = HabitCompletionPoints;

    /// <summary>
    /// Upper inclusive point threshold for a given level L >= 1:
    /// Level 1: 0–100     (max 100)
    /// Level 2: 101–250   (max 250, +150)
    /// Level 3: 251–450   (max 450, +200)
    /// Level 4: 451–700   (max 700, +250)
    /// General formula: MaxPoints(L) = 25 * L * (L + 3)
    /// </summary>
    public int GetMaxPointsForLevel(int level)
    {
        if (level < 1) level = 1;
        return 25 * level * (level + 3);
    }

    public int CalculateLevel(int totalPoints)
    {
        if (totalPoints <= 100) return 1;

        int level = 1;
        while (totalPoints > GetMaxPointsForLevel(level))
        {
            level++;
        }
        return level;
    }

    /// <summary>
    /// Remaining points needed to reach the next level (Level + 1).
    /// </summary>
    public int GetPointsToNextLevel(int totalPoints)
    {
        var currentLevel = CalculateLevel(totalPoints);
        var nextLevelThreshold = GetMaxPointsForLevel(currentLevel) + 1;
        return Math.Max(0, nextLevelThreshold - Math.Max(0, totalPoints));
    }

    public bool AddPoints(User user, int points)
    {
        var oldLevel = user.Level;
        user.TotalPoints = Math.Max(0, user.TotalPoints + points);
        user.Level = CalculateLevel(user.TotalPoints);
        return user.Level > oldLevel;
    }
}
