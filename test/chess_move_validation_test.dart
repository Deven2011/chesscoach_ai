import 'package:en_passant/logic/chess_board.dart';
import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move.dart';
import 'package:en_passant/models/player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chess move validation', () {
    testWidgets('allows a white pawn to move one or two squares from start',
        (tester) async {
      final board = ChessBoard();
      final pawn = board.tiles[52]!;

      expect(pawn.type, ChessPieceType.pawn);
      expect(pawn.player, Player.player1);
      expect(board.movesForPiece(pawn), containsAll(<int>[44, 36]));
    });

    testWidgets('does not allow a pawn to move through a blocking piece',
        (tester) async {
      final board = ChessBoard();
      final pawn = board.tiles[52]!;
      board.push(Move(12, 44));

      expect(board.movesForPiece(pawn), isNot(contains(44)));
      expect(board.movesForPiece(pawn), isNot(contains(36)));
    });

    testWidgets('updates and restores board state when a move is undone',
        (tester) async {
      final board = ChessBoard();
      final startingHash = board.zobristHash;

      board.push(Move(52, 36));

      expect(board.tiles[52], isNull);
      expect(board.tiles[36]?.type, ChessPieceType.pawn);
      expect(board.moveCount, 1);

      board.pop();

      expect(board.tiles[52]?.type, ChessPieceType.pawn);
      expect(board.tiles[36], isNull);
      expect(board.moveCount, 0);
      expect(board.zobristHash, startingHash);
    });
  });
}
