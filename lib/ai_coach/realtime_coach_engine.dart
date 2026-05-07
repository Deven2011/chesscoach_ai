import 'dart:math' as math;

import 'package:en_passant/ai_coach/move_analysis_engine.dart';
import 'package:en_passant/models/move_review_model.dart';

class RealtimeCoachEngine {
  final MoveAnalysisEngine _moveAnalysisEngine;

  const RealtimeCoachEngine({
    MoveAnalysisEngine moveAnalysisEngine = const MoveAnalysisEngine(),
  }) : _moveAnalysisEngine = moveAnalysisEngine;

  Future<MoveReviewModel> analyzeMove(MoveAnalysisInput input) {
    return _moveAnalysisEngine.analyze(input);
  }

  CoachGameSummary summarize(List<MoveReviewModel> reviews) {
    if (reviews.isEmpty) return CoachGameSummary.empty();

    final breakdown = <MoveQuality, int>{};
    for (final review in reviews) {
      breakdown[review.quality] = (breakdown[review.quality] ?? 0) + 1;
    }

    final accuracy = (reviews.fold<int>(
              0,
              (sum, review) => sum + review.qualityScore,
            ) /
            reviews.length)
        .round()
        .clamp(0, 100)
        .toInt();

    final mistakeReviews = reviews
        .where((review) =>
            review.quality == MoveQuality.mistake ||
            review.quality == MoveQuality.blunder)
        .toList();
    final bestMove = reviews.reduce(
      (a, b) => a.qualityScore >= b.qualityScore ? a : b,
    );
    MoveReviewModel? criticalMistake;
    if (mistakeReviews.isNotEmpty) {
      criticalMistake = mistakeReviews.reduce(
        (a, b) => a.centipawnLoss >= b.centipawnLoss ? a : b,
      );
    }

    return CoachGameSummary(
      accuracy: accuracy,
      bestMoveStreak: _bestMoveStreak(reviews),
      mistakes: reviews
          .where((review) => review.quality == MoveQuality.mistake)
          .length,
      blunders: reviews
          .where((review) => review.quality == MoveQuality.blunder)
          .length,
      breakdown: breakdown,
      bestMove: bestMove,
      criticalMistake: criticalMistake,
      turningPoints:
          reviews.where((review) => review.isTurningPoint).take(4).toList(),
      strengths: _strengths(reviews, accuracy),
      weaknesses: _weaknesses(reviews),
    );
  }

  int _bestMoveStreak(List<MoveReviewModel> reviews) {
    var best = 0;
    var current = 0;
    for (final review in reviews) {
      if (review.quality == MoveQuality.best ||
          review.quality == MoveQuality.excellent ||
          review.quality == MoveQuality.brilliant) {
        current++;
        best = math.max(best, current);
      } else {
        current = 0;
      }
    }
    return best;
  }

  List<String> _strengths(List<MoveReviewModel> reviews, int accuracy) {
    final positives = reviews.where((review) => review.isPositive).length;
    final strengths = <String>[];
    if (accuracy >= 80)
      strengths.add('High move accuracy under live pressure.');
    if (positives >= reviews.length * 0.65) {
      strengths.add('Consistent candidate move selection.');
    }
    if (reviews.any((review) => review.quality == MoveQuality.brilliant)) {
      strengths.add('Calculated tactical sacrifices.');
    }
    if (strengths.isEmpty) {
      strengths.add('You completed a reviewable coach game baseline.');
    }
    return strengths;
  }

  List<String> _weaknesses(List<MoveReviewModel> reviews) {
    final weaknesses = <String>[];
    final blunders =
        reviews.where((review) => review.quality == MoveQuality.blunder).length;
    final mistakes =
        reviews.where((review) => review.quality == MoveQuality.mistake).length;
    final misses =
        reviews.where((review) => review.quality == MoveQuality.miss).length;
    if (blunders > 0) {
      weaknesses.add('Reduce major tactical drops with a final blunder scan.');
    }
    if (mistakes + misses >= 2) {
      weaknesses.add('Spend more time comparing forcing candidate moves.');
    }
    if (weaknesses.isEmpty) {
      weaknesses.add('No major recurring weakness detected yet.');
    }
    return weaknesses;
  }
}
