import 'package:en_passant/ai_coach/move_classifier.dart';
import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/models/move_review_model.dart';

class MoveAnalysisEngine {
  final MoveClassifier _classifier;

  const MoveAnalysisEngine({
    MoveClassifier classifier = const MoveClassifier(),
  }) : _classifier = classifier;

  Future<MoveReviewModel> analyze(MoveAnalysisInput input) async {
    final classification = _classifier.classify(input);
    final quality = classification.quality;

    return MoveReviewModel(
      id: '${input.moveNumber}-${input.move.from}-${input.move.to}-${input.createdAt.microsecondsSinceEpoch}',
      moveNumber: input.moveNumber,
      player: input.player,
      move: input.move,
      pieceType: input.pieceType,
      quality: quality,
      beforeEval: input.beforeEval,
      afterEval: input.afterEval,
      bestEval: input.bestEval,
      centipawnLoss: classification.centipawnLoss,
      playerGain: classification.playerGain,
      bestMove: input.bestMove,
      title: _title(quality),
      feedback: _feedback(input, quality, classification),
      suggestion: _suggestion(input, quality, classification),
      isTurningPoint: _isTurningPoint(quality, classification),
      reviewedAt: DateTime.now(),
    );
  }

  String _title(MoveQuality quality) {
    switch (quality) {
      case MoveQuality.brilliant:
        return 'Brilliant Move!';
      case MoveQuality.great:
        return 'Great Move';
      case MoveQuality.best:
        return 'Best Move';
      case MoveQuality.excellent:
        return 'Excellent Tactical Idea';
      case MoveQuality.good:
        return 'Good Move';
      case MoveQuality.inaccuracy:
        return 'Inaccuracy';
      case MoveQuality.miss:
        return 'Missed Opportunity';
      case MoveQuality.mistake:
        return 'Mistake Detected';
      case MoveQuality.blunder:
        return 'Blunder Detected';
    }
  }

  String _feedback(
    MoveAnalysisInput input,
    MoveQuality quality,
    MoveClassification classification,
  ) {
    if (input.bestMoveWasMate && !input.isCheckmate) {
      return 'There was a forcing checkmate available, but this move let the chance slip.';
    }
    if (input.isCheckmate) {
      return 'You found the decisive finishing move and ended the game cleanly.';
    }
    if (quality == MoveQuality.brilliant) {
      return 'A brave sacrifice that improves your position. That is the kind of calculated risk strong players look for.';
    }
    if (classification.playerGain > 100) {
      return 'This move improves your position by ${classification.playerGain} centipawns.';
    }
    if (classification.centipawnLoss > 0) {
      return 'The engine estimate shows a ${classification.centipawnLoss} centipawn loss from the best available option.';
    }
    return 'This keeps your evaluation stable and preserves your plan.';
  }

  String _suggestion(
    MoveAnalysisInput input,
    MoveQuality quality,
    MoveClassification classification,
  ) {
    if (quality == MoveQuality.blunder) {
      return 'Before committing, scan for checks, captures, and undefended pieces.';
    }
    if (quality == MoveQuality.mistake || quality == MoveQuality.miss) {
      return 'Pause on forcing moves and compare your candidate against the opponent response.';
    }
    if (quality == MoveQuality.inaccuracy) {
      return 'Look for a slightly more active piece placement or safer king-side structure.';
    }
    if (input.isCapture && classification.playerGain <= 0) {
      return 'Captures still need a purpose. Check whether the captured piece was protected.';
    }
    if (input.pieceType == ChessPieceType.knight) {
      return 'Knight activity is useful here. Keep an eye on forks and central outposts.';
    }
    if (quality == MoveQuality.best || quality == MoveQuality.excellent) {
      return 'Good calculation. Keep using this checks-captures-threats rhythm.';
    }
    return 'Stay consistent and keep improving piece coordination.';
  }

  bool _isTurningPoint(
    MoveQuality quality,
    MoveClassification classification,
  ) {
    return quality == MoveQuality.brilliant ||
        quality == MoveQuality.blunder ||
        classification.playerGain.abs() >= 180 ||
        classification.centipawnLoss >= 180;
  }
}
