import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/models/match_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsModel', () {
    testWidgets('returns empty defaults when there are no matches',
        (tester) async {
      final analytics = AnalyticsModel.fromMatches(const []);

      expect(analytics.totalMatches, 0);
      expect(analytics.winRate, 0);
      expect(analytics.resultCounts, {'Wins': 0, 'Losses': 0, 'Draws': 0});
      expect(analytics.insights, isNotEmpty);
    });

    testWidgets('calculates totals, win rate, average duration, and streak',
        (tester) async {
      final now = DateTime(2026, 5, 8);
      final analytics = AnalyticsModel.fromMatches([
        _match(
          id: 'latest-win',
          timestamp: now,
          result: MatchResult.win,
          difficulty: 2,
          duration: const Duration(minutes: 2),
        ),
        _match(
          id: 'previous-win',
          timestamp: now.subtract(const Duration(days: 1)),
          result: MatchResult.win,
          difficulty: 2,
          duration: const Duration(minutes: 4),
        ),
        _match(
          id: 'older-loss',
          timestamp: now.subtract(const Duration(days: 2)),
          result: MatchResult.loss,
          difficulty: 3,
          duration: const Duration(minutes: 6),
        ),
      ]);

      expect(analytics.totalMatches, 3);
      expect(analytics.wins, 2);
      expect(analytics.losses, 1);
      expect(analytics.draws, 0);
      expect(analytics.currentStreak, 2);
      expect(analytics.averageDuration, const Duration(minutes: 4));
      expect(analytics.winRate, closeTo(2 / 3, 0.001));
    });

    testWidgets('builds difficulty performance and serializes cleanly',
        (tester) async {
      final analytics = AnalyticsModel.fromMatches([
        _match(id: 'win-1', result: MatchResult.win, difficulty: 2),
        _match(id: 'loss-1', result: MatchResult.loss, difficulty: 2),
        _match(id: 'win-2', result: MatchResult.win, difficulty: 3),
      ]);

      expect(analytics.difficultyPerformance[2]?.matches, 2);
      expect(analytics.difficultyPerformance[2]?.wins, 1);
      expect(analytics.difficultyPerformance[2]?.winRate, 0.5);
      expect(analytics.difficultyPerformance[3]?.winRate, 1);

      final restored = AnalyticsModel.fromMap(analytics.toMap());

      expect(restored.totalMatches, analytics.totalMatches);
      expect(restored.resultCounts, analytics.resultCounts);
      expect(restored.difficultyPerformance[2]?.matches, 2);
    });
  });
}

MatchModel _match({
  required String id,
  MatchResult result = MatchResult.win,
  int difficulty = 1,
  Duration duration = const Duration(minutes: 3),
  DateTime? timestamp,
}) {
  return MatchModel(
    id: id,
    userId: 'user-1',
    winner: result == MatchResult.win ? 'Player' : 'AI',
    gameMode: 'Play vs AI',
    aiDifficulty: difficulty,
    duration: duration,
    moveCount: 20,
    timestamp: timestamp ?? DateTime(2026, 5, 8),
    playerColor: 'White',
    result: result,
  );
}
