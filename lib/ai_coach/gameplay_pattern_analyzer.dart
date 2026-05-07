import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/models/match_model.dart';

class GameplayPatternAnalyzer {
  const GameplayPatternAnalyzer();

  GameplayPatternReport analyze(List<MatchModel> matches) {
    final sorted = [...matches]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (sorted.isEmpty) return GameplayPatternReport.empty();

    final recent = sorted.take(5).toList();
    final previous = sorted.skip(5).take(5).toList();
    final durationSeconds = sorted.fold<int>(
      0,
      (sum, match) => sum + match.duration.inSeconds,
    );
    final totalMoves = sorted.fold<int>(
      0,
      (sum, match) => sum + match.moveCount,
    );
    final validMoveTimes =
        sorted.where((match) => match.averageMoveSeconds > 0).toList();
    final averageMoveSeconds = validMoveTimes.isEmpty
        ? _safeAverageMoveSeconds(sorted)
        : validMoveTimes.fold<double>(
              0,
              (sum, match) => sum + match.averageMoveSeconds,
            ) /
            validMoveTimes.length;

    final fastMatches = sorted
        .where((match) => _moveSeconds(match) > 0 && _moveSeconds(match) <= 8)
        .toList();
    final slowMatches =
        sorted.where((match) => _moveSeconds(match) >= 14).toList();
    final aggressiveMatches =
        sorted.where((match) => match.aggressionScore >= 0.42).toList();
    final defensiveMatches =
        sorted.where((match) => match.defenseScore >= 0.35).toList();

    return GameplayPatternReport(
      matches: sorted,
      totalMatches: sorted.length,
      winRate: _winRate(sorted),
      recentWinRate: _winRate(recent),
      previousWinRate: _winRate(previous),
      averageDuration: Duration(seconds: durationSeconds ~/ sorted.length),
      averageMoveCount: totalMoves / sorted.length,
      averageMoveSeconds: averageMoveSeconds,
      currentWinStreak: _currentStreak(sorted, MatchResult.win),
      currentLossStreak: _currentStreak(sorted, MatchResult.loss),
      colorWinRates: _ratesByString(sorted, (match) => match.playerColor),
      difficultyWinRates: _ratesByInt(
        sorted.where((match) => match.aiDifficulty > 0).toList(),
        (match) => match.aiDifficulty,
      ),
      openingWinRates: _ratesByString(
        sorted.where((match) => match.openingFamily != 'Unclassified').toList(),
        (match) => match.openingFamily,
      ),
      lossPhaseCounts: _lossPhaseCounts(sorted),
      fastWinRate: _winRate(fastMatches),
      slowWinRate: _winRate(slowMatches),
      aggressiveWinRate: _winRate(aggressiveMatches),
      defensiveWinRate: _winRate(defensiveMatches),
      aggressiveMatches: aggressiveMatches.length,
      defensiveMatches: defensiveMatches.length,
      fastMatches: fastMatches.length,
      slowMatches: slowMatches.length,
      improvingDifficulty: _improvingDifficulty(recent, previous),
    );
  }

  int _currentStreak(List<MatchModel> matches, MatchResult result) {
    var streak = 0;
    for (final match in matches) {
      if (match.result != result) break;
      streak++;
    }
    return streak;
  }

  Map<String, double> _ratesByString(
    List<MatchModel> matches,
    String Function(MatchModel match) keyOf,
  ) {
    final groups = <String, List<MatchModel>>{};
    for (final match in matches) {
      groups.putIfAbsent(keyOf(match), () => []).add(match);
    }
    return groups.map((key, value) => MapEntry(key, _winRate(value)));
  }

  Map<int, double> _ratesByInt(
    List<MatchModel> matches,
    int Function(MatchModel match) keyOf,
  ) {
    final groups = <int, List<MatchModel>>{};
    for (final match in matches) {
      groups.putIfAbsent(keyOf(match), () => []).add(match);
    }
    return groups.map((key, value) => MapEntry(key, _winRate(value)));
  }

  Map<String, int> _lossPhaseCounts(List<MatchModel> matches) {
    final losses = matches.where((match) => match.result == MatchResult.loss);
    final counts = <String, int>{'opening': 0, 'middlegame': 0, 'endgame': 0};
    for (final match in losses) {
      final phase = match.lossPhase.isNotEmpty
          ? match.lossPhase
          : _phaseFromMoveCount(match.moveCount);
      counts[phase] = (counts[phase] ?? 0) + 1;
    }
    return counts;
  }

  DifficultyTrend? _improvingDifficulty(
    List<MatchModel> recent,
    List<MatchModel> previous,
  ) {
    DifficultyTrend? best;
    for (var difficulty = 1; difficulty <= 5; difficulty++) {
      final recentMatches =
          recent.where((match) => match.aiDifficulty == difficulty).toList();
      final previousMatches =
          previous.where((match) => match.aiDifficulty == difficulty).toList();
      if (recentMatches.length < 2 || previousMatches.length < 2) continue;

      final delta = _winRate(recentMatches) - _winRate(previousMatches);
      if (delta <= 0) continue;
      final trend = DifficultyTrend(difficulty: difficulty, delta: delta);
      if (best == null || trend.delta > best.delta) best = trend;
    }
    return best;
  }

  double _winRate(List<MatchModel> matches) {
    if (matches.isEmpty) return 0;
    final wins =
        matches.where((match) => match.result == MatchResult.win).length;
    return wins / matches.length;
  }

  double _safeAverageMoveSeconds(List<MatchModel> matches) {
    final valid = matches.where((match) => match.moveCount > 0).toList();
    if (valid.isEmpty) return 0;
    final total = valid.fold<double>(
      0,
      (sum, match) => sum + match.duration.inSeconds / match.moveCount,
    );
    return total / valid.length;
  }

  double _moveSeconds(MatchModel match) {
    if (match.averageMoveSeconds > 0) return match.averageMoveSeconds;
    if (match.moveCount == 0) return 0;
    return match.duration.inSeconds / match.moveCount;
  }

  String _phaseFromMoveCount(int moveCount) {
    if (moveCount < 20) return 'opening';
    if (moveCount <= 60) return 'middlegame';
    return 'endgame';
  }
}

class GameplayPatternReport {
  final List<MatchModel> matches;
  final int totalMatches;
  final double winRate;
  final double recentWinRate;
  final double previousWinRate;
  final Duration averageDuration;
  final double averageMoveCount;
  final double averageMoveSeconds;
  final int currentWinStreak;
  final int currentLossStreak;
  final Map<String, double> colorWinRates;
  final Map<int, double> difficultyWinRates;
  final Map<String, double> openingWinRates;
  final Map<String, int> lossPhaseCounts;
  final double fastWinRate;
  final double slowWinRate;
  final double aggressiveWinRate;
  final double defensiveWinRate;
  final int aggressiveMatches;
  final int defensiveMatches;
  final int fastMatches;
  final int slowMatches;
  final DifficultyTrend? improvingDifficulty;

  const GameplayPatternReport({
    required this.matches,
    required this.totalMatches,
    required this.winRate,
    required this.recentWinRate,
    required this.previousWinRate,
    required this.averageDuration,
    required this.averageMoveCount,
    required this.averageMoveSeconds,
    required this.currentWinStreak,
    required this.currentLossStreak,
    required this.colorWinRates,
    required this.difficultyWinRates,
    required this.openingWinRates,
    required this.lossPhaseCounts,
    required this.fastWinRate,
    required this.slowWinRate,
    required this.aggressiveWinRate,
    required this.defensiveWinRate,
    required this.aggressiveMatches,
    required this.defensiveMatches,
    required this.fastMatches,
    required this.slowMatches,
    required this.improvingDifficulty,
  });

  factory GameplayPatternReport.empty() {
    return const GameplayPatternReport(
      matches: [],
      totalMatches: 0,
      winRate: 0,
      recentWinRate: 0,
      previousWinRate: 0,
      averageDuration: Duration.zero,
      averageMoveCount: 0,
      averageMoveSeconds: 0,
      currentWinStreak: 0,
      currentLossStreak: 0,
      colorWinRates: {},
      difficultyWinRates: {},
      openingWinRates: {},
      lossPhaseCounts: {'opening': 0, 'middlegame': 0, 'endgame': 0},
      fastWinRate: 0,
      slowWinRate: 0,
      aggressiveWinRate: 0,
      defensiveWinRate: 0,
      aggressiveMatches: 0,
      defensiveMatches: 0,
      fastMatches: 0,
      slowMatches: 0,
      improvingDifficulty: null,
    );
  }

  bool get hasEnoughData => totalMatches >= 3;
  double get trendDelta => recentWinRate - previousWinRate;

  String get bestColor => _bestStringKey(colorWinRates);
  String get bestOpening => _bestStringKey(openingWinRates);
  String get weakestPhase {
    if (lossPhaseCounts.isEmpty) return '';
    return lossPhaseCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  int get mostSuccessfulDifficulty {
    if (difficultyWinRates.isEmpty) return 0;
    return difficultyWinRates.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  String _bestStringKey(Map<String, double> values) {
    if (values.isEmpty) return '';
    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

class DifficultyTrend {
  final int difficulty;
  final double delta;

  const DifficultyTrend({
    required this.difficulty,
    required this.delta,
  });

  String get label => AnalyticsModel.difficultyLabel(difficulty);
}
