using Foxio.API.Entities;

namespace Foxio.API.Services;

public interface IGamificationService
{
    int CalculateLevel(int totalPoints);
    bool AddPoints(User user, int points); // returns true if leveled up
}

public class GamificationService : IGamificationService
{
    public const int PointsPerTodo = 10;
    public const int PointsPerHabit = 15;

    public int CalculateLevel(int totalPoints)
    {
        if (totalPoints <= 0) return 1;
        // Level 1: 0 - 100
        // Level 2: 101 - 250
        // Level 3: 251 - 450
        // Level 4: 451 - 700
        // Formulasi progresif: Level = 1 + floor(sqrt(points / 25))
        return 1 + (int)Math.Floor(Math.Sqrt(totalPoints / 25.0));
    }

    public bool AddPoints(User user, int points)
    {
        var oldLevel = user.Level;
        user.TotalPoints = Math.Max(0, user.TotalPoints + points);
        user.Level = CalculateLevel(user.TotalPoints);
        return user.Level > oldLevel;
    }
}
