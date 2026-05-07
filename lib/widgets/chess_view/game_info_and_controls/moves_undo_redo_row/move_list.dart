import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move_meta.dart';
import 'package:en_passant/logic/shared_functions.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/player.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class MoveList extends StatelessWidget {
  final AppModel appModel;
  final ScrollController scrollController = ScrollController();

  MoveList(this.appModel, {super.key});

  void _copyMovesToClipboard(BuildContext context) {
    final moves = _allMoves();
    if (moves.isEmpty) return;
    Clipboard.setData(ClipboardData(text: moves));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Moves copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        width: 250,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return GestureDetector(
      onLongPress: () => _copyMovesToClipboard(context),
      child: Container(
        height: 70 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.symmetric(
            vertical: 12 * scale,
            horizontal: 16 * scale,
          ),
          child: Text(
            _allMoves().isEmpty ? 'No moves yet' : _allMoves(),
            style: AppTextStyles.monoCode(context).copyWith(
              fontSize: 13 * scale,
              color: _allMoves().isEmpty
                  ? AppColors.onSurfaceVariant.withOpacity(0.5)
                  : AppColors.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (appModel.moveListUpdated && scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      appModel.moveListUpdated = false;
    }
  }

  String _allMoves() {
    var moveString = '';
    appModel.moveMetaList.asMap().forEach((index, move) {
      var turnNumber = ((index + 1) / 2).ceil();
      if (index % 2 == 0) {
        moveString += index == 0 ? '$turnNumber. ' : '\n$turnNumber. ';
      }
      moveString += _moveToString(move);
      if (index % 2 == 0) {
        moveString += ' ';
      }
    });
    if (appModel.gameOver) {
      if (appModel.turn == Player.player1) {
        moveString += ' ';
      }
      if (appModel.stalemate) {
        moveString += '  ½-½';
      } else {
        moveString += appModel.turn == Player.player2 ? '  1-0' : '  0-1';
      }
    }
    return moveString;
  }

  String _moveToString(MoveMeta meta) {
    String move;
    if (meta.kingCastle) {
      move = 'O-O';
    } else if (meta.queenCastle) {
      move = 'O-O-O';
    } else {
      String ambiguity = meta.rowIsAmbiguous
          ? '${_colToChar(tileToCol(meta.move?.from ?? 0))}'
          : '';
      ambiguity +=
          meta.colIsAmbiguous ? '${8 - tileToRow(meta.move?.from ?? 0)}' : '';
      String takeString = meta.took ? 'x' : '';
      String promotion = meta.promotion
          ? '=${_pieceToChar(meta.promotionType ?? ChessPieceType.promotion)}'
          : '';
      String row = '${8 - tileToRow(meta.move?.to ?? 0)}';
      String col = '${_colToChar(tileToCol(meta.move?.to ?? 0))}';
      move =
          '${_pieceToChar(meta.type ?? ChessPieceType.promotion)}$ambiguity$takeString' +
              '$col$row$promotion';
    }
    String check = meta.isCheck ? '+' : '';
    String checkmate = meta.isCheckmate && !meta.isStalemate ? '#' : '';
    return move + '$check$checkmate';
  }

  String _pieceToChar(ChessPieceType type) {
    switch (type) {
      case ChessPieceType.king: return 'K';
      case ChessPieceType.queen: return 'Q';
      case ChessPieceType.rook: return 'R';
      case ChessPieceType.bishop: return 'B';
      case ChessPieceType.knight: return 'N';
      case ChessPieceType.pawn: return '';
      default: return '?';
    }
  }

  String _colToChar(int col) {
    return String.fromCharCode(97 + col);
  }
}
