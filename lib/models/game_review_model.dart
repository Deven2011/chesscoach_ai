import 'package:en_passant/models/move_review_model.dart';

class GameReviewModel {
  final int accuracy;
  final int moveCount;
  final int blunders;
  final int mistakes;
  final int brilliantMoves;
  final int bestMoveStreak;
  final String strongestPhase;
  final String weakestPhase;
  final String headline;
  final List<String> coachSummary;
  final Map<MoveQuality, int> qualityDistribution;
  final List<MoveReviewModel> turningPoints;
  final MoveReviewModel? criticalMistake;
  final MoveReviewModel? bestMove;
  final List<int> evaluations;

  const GameReviewModel({
    required this.accuracy,
    required this.moveCount,
    required this.blunders,
    required this.mistakes,
    required this.brilliantMoves,
    required this.bestMoveStreak,
    required this.strongestPhase,
    required this.weakestPhase,
    required this.headline,
    required this.coachSummary,
    required this.qualityDistribution,
    required this.turningPoints,
    required this.criticalMistake,
    required this.bestMove,
    required this.evaluations,
  });

  factory GameReviewModel.empty() {
    return const GameReviewModel(
      accuracy: 0,
      moveCount: 0,
      blunders: 0,
      mistakes: 0,
      brilliantMoves: 0,
      bestMoveStreak: 0,
      strongestPhase: 'Opening',
      weakestPhase: 'Opening',
      headline: 'No review data yet',
      coachSummary: ['Complete a coach game to unlock the full review.'],
      qualityDistribution: {},
      turningPoints: [],
      criticalMistake: null,
      bestMove: null,
      evaluations: [],
    );
  }
}
