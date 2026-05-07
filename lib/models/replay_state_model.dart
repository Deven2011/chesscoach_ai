import 'package:en_passant/logic/chess_board.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move.dart';
import 'package:en_passant/logic/move_calculation/move_classes/move_meta.dart';
import 'package:en_passant/models/move_review_model.dart';

class ReplayStateModel {
  final ChessBoard board;
  final List<Move> moves;
  final List<MoveMeta> moveMetas;
  final List<MoveReviewModel> reviews;
  final int currentMoveIndex;
  final bool isPlaying;
  final double playbackSpeed;
  final bool isLoading;
  final String? errorMessage;

  const ReplayStateModel({
    required this.board,
    required this.moves,
    required this.moveMetas,
    required this.reviews,
    required this.currentMoveIndex,
    required this.isPlaying,
    required this.playbackSpeed,
    required this.isLoading,
    required this.errorMessage,
  });

  factory ReplayStateModel.initial() {
    return ReplayStateModel(
      board: ChessBoard(),
      moves: const [],
      moveMetas: const [],
      reviews: const [],
      currentMoveIndex: 0,
      isPlaying: false,
      playbackSpeed: 1,
      isLoading: false,
      errorMessage: null,
    );
  }

  Move? get latestMove {
    if (currentMoveIndex == 0 || moves.isEmpty) return null;
    return moves[currentMoveIndex - 1];
  }

  MoveReviewModel? get currentReview {
    if (currentMoveIndex == 0) return null;
    final moveNumber = currentMoveIndex;
    for (final review in reviews) {
      if (review.moveNumber == moveNumber) return review;
    }
    return null;
  }

  double get progress {
    if (moves.isEmpty) return 0;
    return currentMoveIndex / moves.length;
  }

  bool get canGoPrevious => currentMoveIndex > 0;
  bool get canGoNext => currentMoveIndex < moves.length;

  ReplayStateModel copyWith({
    ChessBoard? board,
    List<Move>? moves,
    List<MoveMeta>? moveMetas,
    List<MoveReviewModel>? reviews,
    int? currentMoveIndex,
    bool? isPlaying,
    double? playbackSpeed,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReplayStateModel(
      board: board ?? this.board,
      moves: moves ?? this.moves,
      moveMetas: moveMetas ?? this.moveMetas,
      reviews: reviews ?? this.reviews,
      currentMoveIndex: currentMoveIndex ?? this.currentMoveIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
