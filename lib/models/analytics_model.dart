import 'package:en_passant/models/match_model.dart';

class AnalyticsModel {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final int currentStreak;
  final Duration averageDuration;
  final double winRate;
  final Map<int, DifficultyPerformance> difficultyPerformance;
  final Map<String, int> resultCounts;
  final List<String> insights;
  final List<MatchModel> recentMatches;

  const AnalyticsModel({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.currentStreak,
    required this.averageDuration,
    required this.winRate,
    required this.difficultyPerformance,
    required this.resultCounts,
    required this.insights,
    required this.recentMatches,
  });

  factory AnalyticsModel.empty() {
    return const AnalyticsModel(
      totalMatches: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      currentStreak: 0,
      averageDuration: Duration.zero,
      winRate: 0,
      difficultyPerformance: {},
      resultCounts: {'Wins': 0, 'Losses': 0, 'Draws': 0},
      insights: [
        'Play your first match to unlock personalized insights.',
        'Analytics will track your strengths by color and AI difficulty.',
      ],
      recentMatches: [],
    );
  }

  factory AnalyticsModel.fromMatches(List<MatchModel> matches) {
    if (matches.isEmpty) return AnalyticsModel.empty();

    final sorted = [...matches]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final wins = matches.where((m) => m.result == MatchResult.win).length;
    final losses = matches.where((m) => m.result == MatchResult.loss).length;
    final draws = matches.where((m) => m.result == MatchResult.draw).length;
    final totalSeconds = matches.fold<int>(
      0,
      (sum, match) => sum + match.duration.inSeconds,
    );
    final byDifficulty = _difficultyStats(matches);

    return AnalyticsModel(
      totalMatches: matches.length,
      wins: wins,
      losses: losses,
      draws: draws,
      currentStreak: _currentWinStreak(sorted),
      averageDuration: Duration(seconds: totalSeconds ~/ matches.length),
      winRate: wins / matches.length,
      difficultyPerformance: byDifficulty,
      resultCounts: {
        'Wins': wins,
        'Losses': losses,
        'Draws': draws,
      },
      insights: _buildInsights(matches, byDifficulty),
      recentMatches: sorted.take(5).toList(),
    );
  }

  factory AnalyticsModel.fromMap(Map<String, dynamic> map) {
    final matches = (map['recentMatches'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((match) => MatchModel.fromMap(Map<String, dynamic>.from(match)))
        .toList();

    return AnalyticsModel(
      totalMatches: map['totalMatches'] as int? ?? 0,
      wins: map['wins'] as int? ?? 0,
      losses: map['losses'] as int? ?? 0,
      draws: map['draws'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      averageDuration:
          Duration(seconds: map['averageDurationSeconds'] as int? ?? 0),
      winRate: (map['winRate'] as num?)?.toDouble() ?? 0,
      difficultyPerformance:
          _difficultyPerformanceFromMap(map['difficultyPerformance']),
      resultCounts: Map<String, int>.from(map['resultCounts'] as Map? ?? {}),
      insights: List<String>.from(map['insights'] as List? ?? []),
      recentMatches: matches,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'currentStreak': currentStreak,
      'averageDurationSeconds': averageDuration.inSeconds,
      'winRate': winRate,
      'difficultyPerformance': difficultyPerformance.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
      'resultCounts': resultCounts,
      'insights': insights,
      'recentMatches': recentMatches.map((match) => match.toMap()).toList(),
    };
  }

  static Map<int, DifficultyPerformance> _difficultyPerformanceFromMap(
    Object? value,
  ) {
    final data = value as Map? ?? {};
    return data.map((key, rawValue) {
      final map = Map<String, dynamic>.from(rawValue as Map? ?? {});
      final difficulty = int.tryParse(key.toString()) ??
          (map['difficulty'] as int?) ??
          0;
      return MapEntry(
        difficulty,
        DifficultyPerformance.fromMap(map, fallbackDifficulty: difficulty),
      );
    });
  }

  static int _currentWinStreak(List<MatchModel> sortedMatches) {
    var streak = 0;
    for (final match in sortedMatches) {
      if (match.result == MatchResult.win) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static Map<int, DifficultyPerformance> _difficultyStats(
    List<MatchModel> matches,
  ) {
    final aiMatches = matches.where((m) => m.aiDifficulty > 0);
    final grouped = <int, List<MatchModel>>{};
    for (final match in aiMatches) {
      grouped.putIfAbsent(match.aiDifficulty, () => []).add(match);
    }

    return grouped.map((difficulty, matches) {
      final wins = matches.where((m) => m.result == MatchResult.win).length;
      return MapEntry(
        difficulty,
        DifficultyPerformance(
          difficulty: difficulty,
          matches: matches.length,
          wins: wins,
          winRate: matches.isEmpty ? 0 : wins / matches.length,
        ),
      );
    });
  }

  static List<String> _buildInsights(
    List<MatchModel> matches,
    Map<int, DifficultyPerformance> difficultyPerformance,
  ) {
    final insights = <String>[];
    final whiteMatches =
        matches.where((m) => m.playerColor == 'White').toList();
    final blackMatches =
        matches.where((m) => m.playerColor == 'Black').toList();
    final whiteRate = _winRate(whiteMatches);
    final blackRate = _winRate(blackMatches);

    if (whiteMatches.length >= 2 && blackMatches.length >= 2) {
      insights.add(
        blackRate > whiteRate
            ? 'You perform better with black pieces.'
            : 'You perform better with white pieces.',
      );
    }

    if (difficultyPerformance.isNotEmpty) {
      final best = difficultyPerformance.values.reduce(
        (a, b) => a.winRate >= b.winRate ? a : b,
      );
      insights.add(
        'Your win rate against ${difficultyLabel(best.difficulty)} AI is ${(best.winRate * 100).round()}%.',
      );
    }

    final recent = matches.take(5).toList();
    final older = matches.skip(5).take(5).toList();
    if (recent.length >= 3 && older.length >= 3) {
      final recentSpeed = _averageMoveSeconds(recent);
      final olderSpeed = _averageMoveSeconds(older);
      if (recentSpeed > 0 && olderSpeed > 0 && recentSpeed < olderSpeed) {
        insights.add('Your average move speed improved recently.');
      }
    }

    final longMatches = matches
        .where((m) => m.duration.inMinutes >= 20 || m.moveCount >= 60)
        .toList();
    if (longMatches.length >= 2 && _winRate(longMatches) < 0.45) {
      insights.add('You struggle in long endgames.');
    }

    if (insights.isEmpty) {
      insights.add('Play more matches to unlock deeper personalized insights.');
      insights.add('Try both colors to compare your opening performance.');
    }

    return insights.take(4).toList();
  }

  static double _winRate(List<MatchModel> matches) {
    if (matches.isEmpty) return 0;
    return matches.where((m) => m.result == MatchResult.win).length /
        matches.length;
  }

  static double _averageMoveSeconds(List<MatchModel> matches) {
    final valid = matches.where((m) => m.moveCount > 0).toList();
    if (valid.isEmpty) return 0;
    final total = valid.fold<double>(
      0,
      (sum, match) => sum + match.duration.inSeconds / match.moveCount,
    );
    return total / valid.length;
  }

  static String difficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'easy';
      case 2:
        return 'medium';
      case 3:
        return 'hard';
      case 4:
        return 'expert';
      case 5:
        return 'master';
      default:
        return 'local';
    }
  }
}

class DifficultyPerformance {
  final int difficulty;
  final int matches;
  final int wins;
  final double winRate;

  const DifficultyPerformance({
    required this.difficulty,
    required this.matches,
    required this.wins,
    required this.winRate,
  });

  factory DifficultyPerformance.fromMap(
    Map<String, dynamic> map, {
    int fallbackDifficulty = 0,
  }) {
    return DifficultyPerformance(
      difficulty: map['difficulty'] as int? ?? fallbackDifficulty,
      matches: map['matches'] as int? ?? 0,
      wins: map['wins'] as int? ?? 0,
      winRate: (map['winRate'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'difficulty': difficulty,
      'matches': matches,
      'wins': wins,
      'winRate': winRate,
    };
  }
}
