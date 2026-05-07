import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move.dart';
import 'package:en_passant/models/move_review_model.dart';

class MoveTimelineEntry {
  final int moveNumber;
  final Move move;
  final String notation;
  final MoveQuality? quality;
  final int? evaluation;
  final bool isCritical;

  const MoveTimelineEntry({
    required this.moveNumber,
    required this.move,
    required this.notation,
    required this.quality,
    required this.evaluation,
    required this.isCritical,
  });
}

class MoveTimelineEngine {
  const MoveTimelineEngine();

  List<MoveTimelineEntry> build({
    required List<Move> moves,
    required List<MoveReviewModel> reviews,
  }) {
    return List.generate(moves.length, (index) {
      final moveNumber = index + 1;
      final review = _reviewForMove(reviews, moveNumber);
      return MoveTimelineEntry(
        moveNumber: moveNumber,
        move: moves[index],
        notation: _notation(moves[index], moveNumber),
        quality: review?.quality,
        evaluation: review?.afterEval,
        isCritical: review?.isTurningPoint ?? false,
      );
    });
  }

  List<int> evaluations({
    required List<Move> moves,
    required List<MoveReviewModel> reviews,
  }) {
    if (moves.isEmpty) return const [];
    return List.generate(moves.length, (index) {
      final review = _reviewForMove(reviews, index + 1);
      return review?.afterEval ?? 0;
    });
  }

  MoveReviewModel? _reviewForMove(
    List<MoveReviewModel> reviews,
    int moveNumber,
  ) {
    for (final review in reviews) {
      if (review.moveNumber == moveNumber) return review;
    }
    return null;
  }

  String _notation(Move move, int moveNumber) {
    final ply = (moveNumber + 1) ~/ 2;
    final side = moveNumber.isOdd ? '.' : '...';
    final promotion = move.promotionType == ChessPieceType.promotion
        ? ''
        : '=${_pieceLetter(move.promotionType)}';
    return '$ply$side ${_square(move.from)}-${_square(move.to)}$promotion';
  }

  String _square(int tile) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + tile % 8);
    final rank = 8 - (tile ~/ 8);
    return '$file$rank';
  }

  String _pieceLetter(ChessPieceType type) {
    switch (type) {
      case ChessPieceType.queen:
        return 'Q';
      case ChessPieceType.rook:
        return 'R';
      case ChessPieceType.bishop:
        return 'B';
      case ChessPieceType.knight:
        return 'N';
      case ChessPieceType.king:
        return 'K';
      case ChessPieceType.pawn:
      case ChessPieceType.promotion:
        return '';
    }
  }
}
