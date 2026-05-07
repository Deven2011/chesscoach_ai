import 'package:en_passant/models/puzzle_model.dart';
import 'package:en_passant/models/puzzle_attempt_model.dart';
import 'package:en_passant/models/puzzle_progress_model.dart';
import 'puzzle_validator.dart';

/// Tracks user progress, statistics, and achievements in puzzle solving
class PuzzleProgressTracker {
  /// Updates progress model based on a completed attempt
  static PuzzleProgressModel updateProgress({
    required PuzzleProgressModel currentProgress,
    required PuzzleAttemptModel attempt,
    required PuzzleModel puzzle,
  }) {
    int totalSolved = currentProgress.totalPuzzlesSolved + 1;
    int correctSolutions = attempt.correct
        ? currentProgress.correctSolutions + 1
        : currentProgress.correctSolutions;

    // Calculate new accuracy
    double newAccuracy = (correctSolutions / totalSolved) * 100;

    // Update time spent
    Duration newTotalTime =
        currentProgress.totalTimeSpent + attempt.solvingTime;

    // Update streak
    int newStreak = attempt.correct ? currentProgress.currentStreak + 1 : 0;
    int newLongestStreak = newStreak > currentProgress.longestStreak
        ? newStreak
        : currentProgress.longestStreak;

    // Update category stats
    final updatedCategoryStats =
        Map<String, int>.from(currentProgress.categoryStats);
    updatedCategoryStats[puzzle.category] =
        (updatedCategoryStats[puzzle.category] ?? 0) + 1;

    // Update theme stats
    final updatedThemeStats = Map<String, int>.from(currentProgress.themeStats);
    updatedThemeStats[puzzle.theme] =
        (updatedThemeStats[puzzle.theme] ?? 0) + 1;

    // Update difficulty stats
    final updatedDifficultyStats =
        Map<String, int>.from(currentProgress.difficultyStats);
    updatedDifficultyStats['level_${puzzle.difficulty}'] =
        (updatedDifficultyStats['level_${puzzle.difficulty}'] ?? 0) + 1;

    // Update XP earned
    int newTotalXp =
        currentProgress.totalXpEarned + attempt.xpEarned + attempt.streakBonus;

    // Update recent puzzle ratings
    List<int> newRecentRatings = [...currentProgress.recentPuzzleRatings];
    newRecentRatings.add(puzzle.rating);
    if (newRecentRatings.length > 10) {
      newRecentRatings.removeAt(0);
    }

    // Calculate average solve time
    int averageSolveTime = newTotalTime.inSeconds ~/ totalSolved;

    // Update daily puzzle completion
    DateTime? dailyCompleted = puzzle.isDaily
        ? DateTime.now()
        : currentProgress.dailyPuzzleCompletedDate;

    return currentProgress.copyWith(
      totalPuzzlesSolved: totalSolved,
      correctSolutions: correctSolutions,
      solveAccuracy: newAccuracy,
      totalTimeSpent: newTotalTime,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastSolvedDate: attempt.attemptedAt,
      dailyPuzzleCompletedDate: dailyCompleted,
      totalXpEarned: newTotalXp,
      categoryStats: updatedCategoryStats,
      themeStats: updatedThemeStats,
      difficultyStats: updatedDifficultyStats,
      hintsUsed: currentProgress.hintsUsed + attempt.hintsUsed,
      updatedAt: DateTime.now(),
      recentPuzzleRatings: newRecentRatings,
      averageSolveTime: averageSolveTime,
    );
  }

  /// Checks if daily puzzle already completed today
  static bool hasCompletedDailyToday(PuzzleProgressModel progress) {
    if (progress.dailyPuzzleCompletedDate == null) return false;

    final today = DateTime.now();
    final completed = progress.dailyPuzzleCompletedDate!;

    return today.year == completed.year &&
        today.month == completed.month &&
        today.day == completed.day;
  }

  /// Calculates streak bonus XP
  static int getStreakBonus(int streak) {
    if (streak < 1) return 0;
    if (streak < 3) return 0;
    if (streak < 7) return 10;
    if (streak < 14) return 25;
    if (streak < 30) return 50;
    return 100; // 30+ streak
  }

  /// Gets tier/rank based on total XP
  static String getTierByXp(int totalXp) {
    if (totalXp < 500) return 'Novice';
    if (totalXp < 1500) return 'Beginner';
    if (totalXp < 3500) return 'Intermediate';
    if (totalXp < 7000) return 'Advanced';
    if (totalXp < 12000) return 'Expert';
    if (totalXp < 20000) return 'Master';
    return 'Grandmaster';
  }

  /// Calculates progress towards next tier
  static Map<String, dynamic> getTierProgress(int totalXp) {
    final tiers = [
      {'name': 'Novice', 'min': 0, 'max': 500},
      {'name': 'Beginner', 'min': 500, 'max': 1500},
      {'name': 'Intermediate', 'min': 1500, 'max': 3500},
      {'name': 'Advanced', 'min': 3500, 'max': 7000},
      {'name': 'Expert', 'min': 7000, 'max': 12000},
      {'name': 'Master', 'min': 12000, 'max': 20000},
      {'name': 'Grandmaster', 'min': 20000, 'max': 999999},
    ];

    for (final tier in tiers) {
      final tierMin = tier['min'] as int;
      final tierMax = tier['max'] as int;
      if (totalXp >= tierMin && totalXp < tierMax) {
        final progress = (totalXp - tierMin).toDouble();
        final maxProgress = (tierMax - tierMin).toDouble();
        final percentage = (progress / maxProgress) * 100;

        return {
          'currentTier': tier['name'],
          'nextTier': tier['name'],
          'currentXp': totalXp,
          'tierMinXp': tierMin,
          'tierMaxXp': tierMax,
          'progress': percentage,
          'xpNeeded': tierMax - totalXp,
        };
      }
    }

    return {
      'currentTier': 'Grandmaster',
      'nextTier': 'Grandmaster',
      'currentXp': totalXp,
      'tierMinXp': 20000,
      'tierMaxXp': 999999,
      'progress': 100,
      'xpNeeded': 0,
    };
  }

  /// Gets top strengths based on theme stats
  static List<String> getStrengths(PuzzleProgressModel progress) {
    if (progress.themeStats.isEmpty) return [];

    final sorted = progress.themeStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Gets areas for improvement based on theme stats
  static List<String> getAreasForImprovement(PuzzleProgressModel progress) {
    if (progress.themeStats.isEmpty) return [];

    // Get themes with lowest solve counts
    final sorted = progress.themeStats.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Calculates recommended difficulty for next puzzle
  static int getRecommendedDifficulty(PuzzleProgressModel progress) {
    if (progress.totalPuzzlesSolved < 5) return 1;

    final accuracy = progress.solveAccuracy;

    if (accuracy >= 90) {
      return (progress.difficultyStats.values.fold(1, (a, b) => b > a ? b : a) +
              1)
          .clamp(1, 5)
          .toInt();
    } else if (accuracy >= 75) {
      return (progress.difficultyStats.values.fold(1, (a, b) => b > a ? b : a))
          .clamp(1, 5)
          .toInt();
    } else if (accuracy >= 60) {
      return (progress.difficultyStats.values.fold(1, (a, b) => b > a ? b : a) -
              1)
          .clamp(1, 5)
          .toInt();
    } else {
      return 1;
    }
  }

  /// Gets performance summary
  static Map<String, dynamic> getPerformanceSummary(
    PuzzleProgressModel progress,
  ) {
    return {
      'totalSolved': progress.totalPuzzlesSolved,
      'accuracy': progress.solveAccuracy.toStringAsFixed(1),
      'averageSolveTime': _formatDuration(
        Duration(seconds: progress.averageSolveTime),
      ),
      'currentStreak': progress.currentStreak,
      'longestStreak': progress.longestStreak,
      'totalXp': progress.totalXpEarned,
      'tier': getTierByXp(progress.totalXpEarned),
      'hintsUsed': progress.hintsUsed,
    };
  }

  /// Formats duration for display
  static String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${(duration.inMinutes % 60)}m';
    }
  }

  /// Gets motivation message based on progress
  static String getMotivationMessage(PuzzleProgressModel progress) {
    if (progress.currentStreak >= 30) {
      return '🔥 Unstoppable! 30-day streak!';
    } else if (progress.currentStreak >= 14) {
      return '💪 Excellent consistency!';
    } else if (progress.currentStreak >= 7) {
      return '🌟 Great weekly progress!';
    } else if (progress.currentStreak >= 3) {
      return '👍 Keep the momentum going!';
    } else if (progress.currentStreak == 1) {
      return '🎯 New day, new puzzle!';
    } else if (progress.totalPuzzlesSolved >= 100) {
      return '✨ Century achieved! 100+ puzzles solved!';
    } else if (progress.solveAccuracy >= 90) {
      return '🎯 Excellent accuracy!';
    } else {
      return '🚀 Keep practicing!';
    }
  }

  /// Calculates next milestone
  static Map<String, dynamic> getNextMilestone(PuzzleProgressModel progress) {
    final milestones = [
      {
        'name': 'First Puzzle',
        'value': 1,
        'achieved': progress.totalPuzzlesSolved >= 1
      },
      {
        'name': '10 Puzzles',
        'value': 10,
        'achieved': progress.totalPuzzlesSolved >= 10
      },
      {
        'name': '50 Puzzles',
        'value': 50,
        'achieved': progress.totalPuzzlesSolved >= 50
      },
      {
        'name': '100 Puzzles',
        'value': 100,
        'achieved': progress.totalPuzzlesSolved >= 100
      },
      {
        'name': '500 Puzzles',
        'value': 500,
        'achieved': progress.totalPuzzlesSolved >= 500
      },
      {
        'name': '1000 Puzzles',
        'value': 1000,
        'achieved': progress.totalPuzzlesSolved >= 1000
      },
    ];

    for (final milestone in milestones) {
      if (!(milestone['achieved'] as bool)) {
        return {
          'milestone': milestone['name'],
          'target': milestone['value'],
          'current': progress.totalPuzzlesSolved,
          'remaining':
              (milestone['value'] as int) - progress.totalPuzzlesSolved,
        };
      }
    }

    return {
      'milestone': 'Legend',
      'target': 1000,
      'current': progress.totalPuzzlesSolved,
      'remaining': 0,
    };
  }
}
