import 'package:flutter/material.dart';

import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move.dart';
import 'package:en_passant/models/player.dart';

enum MoveQuality {
  brilliant,
  great,
  best,
  excellent,
  good,
  inaccuracy,
  miss,
  mistake,
  blunder,
}

class MoveAnalysisInput {
  final int moveNumber;
  final Player player;
  final Move move;
  final ChessPieceType? pieceType;
  final int beforeEval;
  final int afterEval;
  final int bestEval;
  final Move? bestMove;
  final bool isCapture;
  final bool isSacrifice;
  final bool isCheck;
  final bool isCheckmate;
  final bool bestMoveWasMate;
  final DateTime createdAt;

  const MoveAnalysisInput({
    required this.moveNumber,
    required this.player,
    required this.move,
    required this.pieceType,
    required this.beforeEval,
    required this.afterEval,
    required this.bestEval,
    required this.bestMove,
    required this.isCapture,
    required this.isSacrifice,
    required this.isCheck,
    required this.isCheckmate,
    required this.bestMoveWasMate,
    required this.createdAt,
  });
}

class MoveReviewModel {
  final String id;
  final int moveNumber;
  final Player player;
  final Move move;
  final ChessPieceType? pieceType;
  final MoveQuality quality;
  final int beforeEval;
  final int afterEval;
  final int bestEval;
  final int centipawnLoss;
  final int playerGain;
  final Move? bestMove;
  final String title;
  final String feedback;
  final String suggestion;
  final bool isTurningPoint;
  final DateTime reviewedAt;

  const MoveReviewModel({
    required this.id,
    required this.moveNumber,
    required this.player,
    required this.move,
    required this.pieceType,
    required this.quality,
    required this.beforeEval,
    required this.afterEval,
    required this.bestEval,
    required this.centipawnLoss,
    required this.playerGain,
    required this.bestMove,
    required this.title,
    required this.feedback,
    required this.suggestion,
    required this.isTurningPoint,
    required this.reviewedAt,
  });

  bool get isPositive =>
      quality == MoveQuality.brilliant ||
      quality == MoveQuality.great ||
      quality == MoveQuality.best ||
      quality == MoveQuality.excellent ||
      quality == MoveQuality.good;

  String get qualityLabel {
    switch (quality) {
      case MoveQuality.brilliant:
        return 'Brilliant';
      case MoveQuality.great:
        return 'Great';
      case MoveQuality.best:
        return 'Best';
      case MoveQuality.excellent:
        return 'Excellent';
      case MoveQuality.good:
        return 'Good';
      case MoveQuality.inaccuracy:
        return 'Inaccuracy';
      case MoveQuality.miss:
        return 'Miss';
      case MoveQuality.mistake:
        return 'Mistake';
      case MoveQuality.blunder:
        return 'Blunder';
    }
  }

  Color get color {
    switch (quality) {
      case MoveQuality.brilliant:
        return const Color(0xFF00D1FF);
      case MoveQuality.great:
        return const Color(0xFFD4AF37);
      case MoveQuality.best:
        return const Color(0xFF10B981);
      case MoveQuality.excellent:
        return const Color(0xFF34D399);
      case MoveQuality.good:
        return const Color(0xFF8BBF61);
      case MoveQuality.inaccuracy:
        return const Color(0xFFF5C542);
      case MoveQuality.miss:
        return const Color(0xFFE6B17A);
      case MoveQuality.mistake:
        return const Color(0xFFF97316);
      case MoveQuality.blunder:
        return const Color(0xFFEF4444);
    }
  }

  int get qualityScore {
    switch (quality) {
      case MoveQuality.brilliant:
        return 100;
      case MoveQuality.great:
        return 94;
      case MoveQuality.best:
        return 92;
      case MoveQuality.excellent:
        return 86;
      case MoveQuality.good:
        return 74;
      case MoveQuality.inaccuracy:
        return 58;
      case MoveQuality.miss:
        return 44;
      case MoveQuality.mistake:
        return 28;
      case MoveQuality.blunder:
        return 8;
    }
  }
}

class CoachGameSummary {
  final int accuracy;
  final int bestMoveStreak;
  final int mistakes;
  final int blunders;
  final Map<MoveQuality, int> breakdown;
  final MoveReviewModel? bestMove;
  final MoveReviewModel? criticalMistake;
  final List<MoveReviewModel> turningPoints;
  final List<String> strengths;
  final List<String> weaknesses;

  const CoachGameSummary({
    required this.accuracy,
    required this.bestMoveStreak,
    required this.mistakes,
    required this.blunders,
    required this.breakdown,
    required this.bestMove,
    required this.criticalMistake,
    required this.turningPoints,
    required this.strengths,
    required this.weaknesses,
  });

  factory CoachGameSummary.empty() {
    return const CoachGameSummary(
      accuracy: 0,
      bestMoveStreak: 0,
      mistakes: 0,
      blunders: 0,
      breakdown: {},
      bestMove: null,
      criticalMistake: null,
      turningPoints: [],
      strengths: ['Complete a coach game to unlock a review summary.'],
      weaknesses: [],
    );
  }
}
