import 'package:en_passant/logic/chess_board.dart';
import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move_meta.dart';

class ReplayEngine {
  const ReplayEngine();

  ChessBoard boardAt({
    required List<Move> moves,
    required int moveIndex,
  }) {
    final board = ChessBoard();
    final safeIndex = moveIndex.clamp(0, moves.length).toInt();
    for (var index = 0; index < safeIndex; index++) {
      final move = moves[index];
      board.push(move, promotionType: move.promotionType);
    }
    return board;
  }

  List<MoveMeta> buildMoveMetas(List<Move> moves) {
    final board = ChessBoard();
    final metas = <MoveMeta>[];
    for (final move in moves) {
      final meta = board.push(
        move,
        getMeta: true,
        promotionType: move.promotionType,
      );
      metas.add(meta);
    }
    return metas;
  }

  List<Move> movesFromMetas(List<MoveMeta> metas) {
    return metas
        .map((meta) => meta.move)
        .whereType<Move>()
        .map(
          (move) => Move(
            move.from,
            move.to,
            promotionType: move.promotionType == ChessPieceType.promotion
                ? ChessPieceType.promotion
                : move.promotionType,
          ),
        )
        .toList();
  }

  List<int> evaluationsForMoves(List<Move> moves) {
    final board = ChessBoard();
    final evaluations = <int>[];
    for (final move in moves) {
      board.push(move, promotionType: move.promotionType);
      evaluations.add(board.boardValue);
    }
    return evaluations;
  }
}
