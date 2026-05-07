import 'dart:math' as math;

import 'package:en_passant/logic/move_calculation/move_classes/move.dart';
import 'package:en_passant/models/move_review_model.dart';
import 'package:en_passant/models/player.dart';

class MoveClassifier {
  const MoveClassifier();

  MoveClassification classify(MoveAnalysisInput input) {
    final beforeScore = _scoreForPlayer(input.beforeEval, input.player);
    final afterScore = _scoreForPlayer(input.afterEval, input.player);
    final bestScore = _scoreForPlayer(input.bestEval, input.player);
    final centipawnLoss = math.max(0, bestScore - afterScore);
    final playerGain = afterScore - beforeScore;
    final playedBestMove = _sameMove(input.move, input.bestMove);

    if (input.bestMoveWasMate && !input.isCheckmate) {
      return MoveClassification(
        quality: centipawnLoss >= 220 ? MoveQuality.blunder : MoveQuality.miss,
        centipawnLoss: centipawnLoss,
        playerGain: playerGain,
      );
    }

    if (input.isSacrifice && playerGain >= 120 && centipawnLoss <= 30) {
      return MoveClassification(
        quality: MoveQuality.brilliant,
        centipawnLoss: centipawnLoss,
        playerGain: playerGain,
      );
    }

    if (input.isCheckmate ||
        (playedBestMove && centipawnLoss <= 12 && playerGain >= 80)) {
      return MoveClassification(
        quality: MoveQuality.best,
        centipawnLoss: centipawnLoss,
        playerGain: playerGain,
      );
    }

    if (playerGain >= 120 && centipawnLoss <= 35) {
      return MoveClassification(
        quality: MoveQuality.great,
        centipawnLoss: centipawnLoss,
        playerGain: playerGain,
      );
    }

    final quality = _qualityFromLoss(
      centipawnLoss: centipawnLoss,
      playedBestMove: playedBestMove,
    );

    return MoveClassification(
      quality: quality,
      centipawnLoss: centipawnLoss,
      playerGain: playerGain,
    );
  }

  int _scoreForPlayer(int boardEval, Player player) {
    return player == Player.player1 ? boardEval : -boardEval;
  }

  bool _sameMove(Move move, Move? other) {
    return other != null &&
        move.from == other.from &&
        move.to == other.to &&
        move.promotionType == other.promotionType;
  }

  MoveQuality _qualityFromLoss({
    required int centipawnLoss,
    required bool playedBestMove,
  }) {
    if (centipawnLoss <= 12 && playedBestMove) return MoveQuality.best;
    if (centipawnLoss <= 25) return MoveQuality.excellent;
    if (centipawnLoss <= 55) return MoveQuality.good;
    if (centipawnLoss <= 95) return MoveQuality.inaccuracy;
    if (centipawnLoss <= 150) return MoveQuality.miss;
    if (centipawnLoss <= 260) return MoveQuality.mistake;
    return MoveQuality.blunder;
  }
}

class MoveClassification {
  final MoveQuality quality;
  final int centipawnLoss;
  final int playerGain;

  const MoveClassification({
    required this.quality,
    required this.centipawnLoss,
    required this.playerGain,
  });
}
