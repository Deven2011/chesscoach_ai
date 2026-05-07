import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

import 'package:en_passant/models/app_model.dart';

import 'package:en_passant/logic/chess_board.dart';
import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/logic/move_calculation/ai_move_calculation.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move_meta.dart';
import 'package:en_passant/logic/shared_functions.dart';
import 'package:en_passant/models/move_review_model.dart';
import 'package:en_passant/models/player.dart';

Move? _calculateAIMove(Map<String, Object> args) => calculateAIMove(args);

/// Handles game logic orchestration: move execution, AI, undo/redo, promotion.
/// Separated from ChessGame (the view/rendering layer) for clean MVVM.
class GameController {
  final AppModel appModel;
  final ChessBoard board = ChessBoard();

  CancelableOperation<Move?>? aiOperation;
  List<int> validMoves = [];
  ChessPiece? selectedPiece;
  int? checkHintTile;
  Move? latestMove;
  _CoachMoveSeed? _pendingPromotionCoachSeed;

  /// Called when the view needs to refresh sprites (e.g. after game restore).
  VoidCallback? onSnapSprites;

  GameController(this.appModel);

  // ── Piece Selection ──

  void selectPiece(ChessPiece? piece) {
    if (piece != null) {
      if (piece.player == appModel.turn) {
        selectedPiece = piece;
        if (selectedPiece != null) {
          validMoves = board.movesForPiece(piece);
        }
        if (validMoves.isEmpty) {
          selectedPiece = null;
        }
      }
    }
  }

  void movePiece(int tile) {
    if (validMoves.contains(tile)) {
      final piece = selectedPiece;
      final coachSeed = appModel.coachModeEnabled &&
              piece != null &&
              piece.player == appModel.playerSide
          ? _buildCoachMoveSeed(piece, tile)
          : null;
      validMoves = [];
      var meta =
          board.push(Move(selectedPiece?.tile ?? 0, tile), getMeta: true);
      appModel.audio.playMovedSound();
      if (meta.promotion) {
        _pendingPromotionCoachSeed = coachSeed;
        appModel.requestPromotion();
      }
      _moveCompletion(
        meta,
        changeTurn: !meta.promotion,
        coachSeed: meta.promotion ? null : coachSeed,
      );
    }
  }

  // ── AI ──

  void _aiMove() async {
    if (appModel.gameOver) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (appModel.gameOver || !appModel.isAIsTurn) return;

    final args = <String, Object>{
      'aiPlayer': appModel.aiTurn,
      'aiDifficulty': appModel.aiDifficulty,
      'board': board,
    };
    final operation = CancelableOperation<Move?>.fromFuture(
      compute<Map<String, Object>, Move?>(_calculateAIMove, args),
    );
    aiOperation = operation;

    operation.value.then((move) {
      if (aiOperation != operation || operation.isCanceled) return;
      aiOperation = null;
      if (move == null || appModel.gameOver || !appModel.isAIsTurn) return;

      validMoves = [];
      var meta = board.push(move, getMeta: true);
      appModel.audio.playMovedSound();
      _moveCompletion(meta, changeTurn: !meta.promotion);
      if (meta.promotion) {
        promote(move.promotionType);
      }
    });
  }

  void cancelAIMove() {
    aiOperation?.cancel();
    aiOperation = null;
  }

  void triggerAIMove() {
    _aiMove();
  }

  // ── Undo / Redo ──

  void undoMove() {
    board.redoStack.add(board.pop());
    if (appModel.moveMetaList.length > 1) {
      var meta = appModel.moveMetaList[appModel.moveMetaList.length - 2];
      _moveCompletion(meta, clearRedo: false, undoing: true);
    } else {
      _undoOpeningMove();
      appModel.changeTurn();
    }
  }

  void undoTwoMoves() {
    board.redoStack.add(board.pop());
    board.redoStack.add(board.pop());
    appModel.popMoveMeta();
    if (appModel.moveMetaList.length > 1) {
      _moveCompletion(appModel.moveMetaList[appModel.moveMetaList.length - 2],
          clearRedo: false, undoing: true, changeTurn: false);
    } else {
      _undoOpeningMove();
    }
  }

  void _undoOpeningMove() {
    selectedPiece = null;
    validMoves = [];
    latestMove = null;
    checkHintTile = null;
    appModel.popMoveMeta();
  }

  void redoMove() {
    _moveCompletion(board.pushMSO(board.redoStack.removeLast()),
        clearRedo: false);
  }

  void redoTwoMoves() {
    _moveCompletion(board.pushMSO(board.redoStack.removeLast()),
        clearRedo: false, updateMetaList: true);
    _moveCompletion(board.pushMSO(board.redoStack.removeLast()),
        clearRedo: false, updateMetaList: true);
  }

  // ── Promotion ──

  void promote(ChessPieceType type) {
    final coachSeed = _pendingPromotionCoachSeed?.withPromotion(type);
    _pendingPromotionCoachSeed = null;
    board.moveStack.last.movedPiece?.type = type;
    board.moveStack.last.promotionType = type;
    board.addPromotedPiece(board.moveStack.last);
    appModel.moveMetaList.last.promotionType = type;
    _moveCompletion(
      appModel.moveMetaList.last,
      updateMetaList: false,
      coachSeed: coachSeed,
    );
  }

  // ── Move Completion ──

  void _moveCompletion(
    MoveMeta meta, {
    bool clearRedo = true,
    bool undoing = false,
    bool changeTurn = true,
    bool updateMetaList = true,
    _CoachMoveSeed? coachSeed,
  }) async {
    if (clearRedo) {
      board.redoStack = [];
    }
    validMoves = [];
    latestMove = meta.move;
    checkHintTile = null;
    var oppositeTurn = oppositePlayer(appModel.turn);

    // kingInCheck is lightweight (no push/pop), keep synchronous
    if (board.kingInCheck(oppositeTurn)) {
      meta.isCheck = true;
      checkHintTile = board.kingForPlayer(oppositeTurn)?.tile;
    }

    // Run synchronously to avoid expensive object graph serialization in Isolates
    bool isCheckmate = board.kingInCheckmate(oppositeTurn);
    if (isCheckmate) {
      if (!meta.isCheck) {
        appModel.stalemate = true;
        meta.isStalemate = true;
      }
      meta.isCheck = false;
      meta.isCheckmate = true;
      appModel.endGame(silent: true);
    }
    if (undoing) {
      appModel.popMoveMeta(silent: true);
      appModel.undoEndGame(silent: true);
    } else if (updateMetaList) {
      appModel.pushMoveMeta(meta, silent: true);
    }
    if (coachSeed != null && !undoing && appModel.coachModeEnabled) {
      appModel.dispatchRealtimeCoachMove(
        MoveAnalysisInput(
          moveNumber: appModel.moveMetaList.length,
          player: coachSeed.player,
          move: coachSeed.move,
          pieceType: coachSeed.pieceType,
          beforeEval: coachSeed.beforeEval,
          afterEval: board.boardValue,
          bestEval: coachSeed.bestEval,
          bestMove: coachSeed.bestMove,
          isCapture: meta.took,
          isSacrifice: coachSeed.isSacrifice,
          isCheck: meta.isCheck,
          isCheckmate: meta.isCheckmate,
          bestMoveWasMate: coachSeed.bestMoveWasMate,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (changeTurn) {
      appModel.changeTurn(silent: true);
    }
    selectedPiece = null;
    // Single rebuild for all the state changes above
    appModel.update();
    if (appModel.isAIsTurn && clearRedo && changeTurn) {
      _aiMove();
    }
  }

  void snapSprites() {
    onSnapSprites?.call();
  }

  _CoachMoveSeed _buildCoachMoveSeed(ChessPiece piece, int tile) {
    final beforeEval = board.boardValue;
    final target = board.tiles[tile];
    final estimate = _bestMoveEstimate(piece.player);

    return _CoachMoveSeed(
      player: piece.player,
      move: Move(piece.tile, tile),
      pieceType: piece.type,
      beforeEval: beforeEval,
      bestEval: estimate.eval,
      bestMove: estimate.move,
      bestMoveWasMate: estimate.wasMate,
      isSacrifice: target != null &&
          target.player != piece.player &&
          piece.materialValue > target.materialValue + 150,
    );
  }

  _BestMoveEstimate _bestMoveEstimate(Player player) {
    final moves = board.allMoves(player, appModel.aiDifficulty);
    if (moves.isEmpty) {
      return _BestMoveEstimate(
        move: null,
        eval: board.boardValue,
        wasMate: false,
      );
    }

    Move? bestMove;
    var bestEval = player == Player.player1 ? -100000 : 100000;
    var bestWasMate = false;

    for (final move in moves) {
      board.push(move, promotionType: move.promotionType);
      final eval = board.boardValue;
      final wasMate = board.kingInCheckmate(oppositePlayer(player));
      board.pop();

      final isBetter = player == Player.player1
          ? eval > bestEval || (eval == bestEval && wasMate)
          : eval < bestEval || (eval == bestEval && wasMate);
      if (isBetter) {
        bestEval = eval;
        bestMove = move;
        bestWasMate = wasMate;
      }
    }

    return _BestMoveEstimate(
      move: bestMove,
      eval: bestEval,
      wasMate: bestWasMate,
    );
  }
}

class _CoachMoveSeed {
  final Player player;
  final Move move;
  final ChessPieceType? pieceType;
  final int beforeEval;
  final int bestEval;
  final Move? bestMove;
  final bool bestMoveWasMate;
  final bool isSacrifice;

  const _CoachMoveSeed({
    required this.player,
    required this.move,
    required this.pieceType,
    required this.beforeEval,
    required this.bestEval,
    required this.bestMove,
    required this.bestMoveWasMate,
    required this.isSacrifice,
  });

  _CoachMoveSeed withPromotion(ChessPieceType promotionType) {
    return _CoachMoveSeed(
      player: player,
      move: Move(move.from, move.to, promotionType: promotionType),
      pieceType: pieceType,
      beforeEval: beforeEval,
      bestEval: bestEval,
      bestMove: bestMove,
      bestMoveWasMate: bestMoveWasMate,
      isSacrifice: isSacrifice,
    );
  }
}

class _BestMoveEstimate {
  final Move? move;
  final int eval;
  final bool wasMate;

  const _BestMoveEstimate({
    required this.move,
    required this.eval,
    required this.wasMate,
  });
}
