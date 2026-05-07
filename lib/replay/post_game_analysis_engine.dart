import 'dart:math' as math;

import 'package:en_passant/models/game_review_model.dart';
import 'package:en_passant/models/move_review_model.dart';

class PostGameAnalysisEngine {
  const PostGameAnalysisEngine();

  GameReviewModel analyze({
    required int moveCount,
    required List<MoveReviewModel> reviews,
    required List<int> evaluations,
  }) {
    if (reviews.isEmpty) {
      return GameReviewModel(
        accuracy: 0,
        moveCount: moveCount,
        blunders: 0,
        mistakes: 0,
        brilliantMoves: 0,
        bestMoveStreak: 0,
        strongestPhase: 'Opening',
        weakestPhase: 'Opening',
        headline: 'Replay ready',
        coachSummary: const [
          'Move-by-move replay is available for this game.',
          'Play Against Coach games include classified move feedback and accuracy.',
        ],
        qualityDistribution: const {},
        turningPoints: const [],
        criticalMistake: null,
        bestMove: null,
        evaluations: evaluations,
      );
    }

    final distribution = <MoveQuality, int>{};
    for (final review in reviews) {
      distribution[review.quality] = (distribution[review.quality] ?? 0) + 1;
    }

    final accuracy = (reviews.fold<int>(
              0,
              (sum, review) => sum + review.qualityScore,
            ) /
            reviews.length)
        .round()
        .clamp(0, 100)
        .toInt();
    final blunders = distribution[MoveQuality.blunder] ?? 0;
    final mistakes = distribution[MoveQuality.mistake] ?? 0;
    final brilliant = distribution[MoveQuality.brilliant] ?? 0;
    final bestMoveStreak = _bestMoveStreak(reviews);
    final phases = _phaseScores(reviews);
    final strongestPhase = _phaseByScore(phases, strongest: true);
    final weakestPhase = _phaseByScore(phases, strongest: false);
    final turningPoints =
        reviews.where((review) => review.isTurningPoint).take(5).toList();
    final criticalMistake = _criticalMistake(reviews);
    final bestMove = reviews.reduce(
      (a, b) => a.qualityScore >= b.qualityScore ? a : b,
    );

    return GameReviewModel(
      accuracy: accuracy,
      moveCount: moveCount,
      blunders: blunders,
      mistakes: mistakes,
      brilliantMoves: brilliant,
      bestMoveStreak: bestMoveStreak,
      strongestPhase: strongestPhase,
      weakestPhase: weakestPhase,
      headline: _headline(accuracy, blunders, mistakes),
      coachSummary: _coachSummary(
        strongestPhase: strongestPhase,
        weakestPhase: weakestPhase,
        criticalMistake: criticalMistake,
        evaluations: evaluations,
        accuracy: accuracy,
      ),
      qualityDistribution: distribution,
      turningPoints: turningPoints,
      criticalMistake: criticalMistake,
      bestMove: bestMove,
      evaluations: evaluations,
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

  Map<String, double> _phaseScores(List<MoveReviewModel> reviews) {
    final buckets = <String, List<MoveReviewModel>>{
      'Opening': [],
      'Middlegame': [],
      'Endgame': [],
    };
    for (final review in reviews) {
      if (review.moveNumber <= 12) {
        buckets['Opening']!.add(review);
      } else if (review.moveNumber <= 40) {
        buckets['Middlegame']!.add(review);
      } else {
        buckets['Endgame']!.add(review);
      }
    }

    return buckets.map((phase, phaseReviews) {
      if (phaseReviews.isEmpty) return MapEntry(phase, 0);
      return MapEntry(
        phase,
        phaseReviews.fold<int>(
              0,
              (sum, review) => sum + review.qualityScore,
            ) /
            phaseReviews.length,
      );
    });
  }

  String _phaseByScore(Map<String, double> scores, {required bool strongest}) {
    final entries = scores.entries.where((entry) => entry.value > 0).toList();
    if (entries.isEmpty) return 'Opening';
    entries.sort((a, b) => strongest
        ? b.value.compareTo(a.value)
        : a.value.compareTo(b.value));
    return entries.first.key;
  }

  MoveReviewModel? _criticalMistake(List<MoveReviewModel> reviews) {
    final mistakes = reviews
        .where((review) =>
            review.quality == MoveQuality.mistake ||
            review.quality == MoveQuality.blunder)
        .toList();
    if (mistakes.isEmpty) return null;
    return mistakes.reduce(
      (a, b) => a.centipawnLoss >= b.centipawnLoss ? a : b,
    );
  }

  String _headline(int accuracy, int blunders, int mistakes) {
    if (accuracy >= 88 && blunders == 0) return 'Clinical conversion';
    if (accuracy >= 75) return 'Strong game with clear learning moments';
    if (blunders > 0) return 'Tactical swings decided the game';
    if (mistakes > 1) return 'Solid ideas, but calculation drifted';
    return 'Useful review baseline established';
  }

  List<String> _coachSummary({
    required String strongestPhase,
    required String weakestPhase,
    required MoveReviewModel? criticalMistake,
    required List<int> evaluations,
    required int accuracy,
  }) {
    final summary = <String>[
      'Your $strongestPhase was significantly stronger than your $weakestPhase.',
    ];
    if (criticalMistake != null) {
      summary.add(
        'The critical moment came on move ${criticalMistake.moveNumber}, where ${criticalMistake.centipawnLoss} centipawns were lost.',
      );
    }
    if (evaluations.length >= 3 &&
        evaluations.last.abs() < evaluations[evaluations.length - 2].abs()) {
      summary.add('You recovered well after a difficult evaluation swing.');
    } else if (accuracy >= 80) {
      summary.add('You kept a stable evaluation profile across the game.');
    } else {
      summary.add('Most improvement will come from checking forcing replies.');
    }
    return summary;
  }
}
