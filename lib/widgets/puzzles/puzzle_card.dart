import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/puzzle_model.dart';

/// Widget displaying an interactive puzzle board.
class PuzzleCard extends StatefulWidget {
  final PuzzleModel puzzle;
  final List<String> playedMoves;
  final ValueChanged<String>? onMoveSelected;
  final bool interactive;

  const PuzzleCard({
    Key? key,
    required this.puzzle,
    this.playedMoves = const [],
    this.onMoveSelected,
    this.interactive = true,
  }) : super(key: key);

  @override
  State<PuzzleCard> createState() => _PuzzleCardState();
}

class _PuzzleCardState extends State<PuzzleCard> {
  String? _selectedSquare;

  @override
  Widget build(BuildContext context) {
    final board = _positionAfterMoves();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.border,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildChessBoard(board),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rating: ${widget.puzzle.rating}',
                      style: AppTextStyles.textTheme().bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${widget.puzzle.category}',
                      style: AppTextStyles.textTheme().bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    '+${widget.puzzle.xpReward} XP',
                    style: AppTextStyles.textTheme().labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChessBoard(Map<String, String> board) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final square = _squareName(row, col);
        final isDark = (row + col) % 2 == 1;
        final isSelected = _selectedSquare == square;
        final piece = board[square];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleSquareTap(square, board),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: _squareColor(
                isDark: isDark,
                isSelected: isSelected,
              ),
              border: Border.all(
                color: isSelected
                    ? AppColors.highlight
                    : AppColors.border.withOpacity(0.25),
                width: isSelected ? 2 : 0.5,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: piece == null
                      ? const SizedBox.shrink()
                      : _buildPieceImage(piece),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, String> _positionAfterMoves() {
    final board = _parseFen(widget.puzzle.fen);
    for (final move in widget.playedMoves) {
      if (move.length < 4) continue;

      final from = move.substring(0, 2).toLowerCase();
      final to = move.substring(2, 4).toLowerCase();
      final piece = board.remove(from);
      if (piece == null) continue;

      if (move.length >= 5) {
        final promotedPiece = move.substring(4, 5);
        board[to] = _isWhitePiece(piece)
            ? promotedPiece.toUpperCase()
            : promotedPiece.toLowerCase();
      } else {
        board[to] = piece;
      }
    }
    return board;
  }

  Map<String, String> _parseFen(String fen) {
    final board = <String, String>{};
    final boardFen = fen.split(' ').first;
    final rows = boardFen.split('/');

    for (var row = 0; row < rows.length && row < 8; row++) {
      var col = 0;
      for (final char in rows[row].split('')) {
        final emptySquares = int.tryParse(char);
        if (emptySquares != null) {
          col += emptySquares;
          continue;
        }

        if (col >= 8) break;
        board[_squareName(row, col)] = char;
        col++;
      }
    }

    return board;
  }

  void _handleSquareTap(String square, Map<String, String> board) {
    if (!widget.interactive || widget.onMoveSelected == null) return;

    final selected = _selectedSquare;
    if (selected == null) {
      if (board.containsKey(square)) {
        setState(() => _selectedSquare = square);
      }
      return;
    }

    if (selected == square) {
      setState(() => _selectedSquare = null);
      return;
    }

    final move = _moveWithPromotionIfNeeded('$selected$square');
    setState(() => _selectedSquare = null);
    widget.onMoveSelected!(move);
  }

  String _moveWithPromotionIfNeeded(String move) {
    final nextMove = _nextExpectedMove();
    if (nextMove != null &&
        nextMove.length == 5 &&
        nextMove.substring(0, 4) == move) {
      return nextMove;
    }
    return move;
  }

  String? _nextExpectedMove() {
    final index = widget.playedMoves.length;
    if (index >= widget.puzzle.solution.length) return null;
    return widget.puzzle.solution[index].toLowerCase();
  }

  String _squareName(int row, int col) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = 8 - row;
    return '$file$rank';
  }

  Color _squareColor({
    required bool isDark,
    required bool isSelected,
  }) {
    if (isSelected) return AppColors.primary.withOpacity(0.5);
    return isDark ? AppColors.surfaceRaised : AppColors.backgroundLight;
  }

  Widget _buildPieceImage(String fenChar) {
    final assetPath = _pieceAssetPath(fenChar);
    if (assetPath == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            fenChar.toUpperCase(),
            style: AppTextStyles.textTheme().headlineSmall?.copyWith(
                  color: _isWhitePiece(fenChar)
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          );
        },
      ),
    );
  }

  String? _pieceAssetPath(String fenChar) {
    final color = _isWhitePiece(fenChar) ? 'white' : 'black';
    final pieceNames = {
      'k': 'king',
      'q': 'queen',
      'r': 'rook',
      'b': 'bishop',
      'n': 'knight',
      'p': 'pawn',
    };

    final pieceName = pieceNames[fenChar.toLowerCase()];
    if (pieceName == null) return null;
    return 'assets/images/pieces/classic/${pieceName}_$color.png';
  }

  bool _isWhitePiece(String fenChar) {
    return fenChar.toUpperCase() == fenChar;
  }
}
