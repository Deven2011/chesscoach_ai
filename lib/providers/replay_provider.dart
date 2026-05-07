import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/game_review_model.dart';
import 'package:en_passant/models/move_review_model.dart';
import 'package:en_passant/models/replay_state_model.dart';
import 'package:en_passant/replay/move_timeline_engine.dart';
import 'package:en_passant/replay/post_game_analysis_engine.dart';
import 'package:en_passant/replay/replay_engine.dart';

class ReplayProvider extends ChangeNotifier {
  final ReplayEngine _replayEngine;
  final MoveTimelineEngine _timelineEngine;
  final PostGameAnalysisEngine _analysisEngine;

  ReplayStateModel _state = ReplayStateModel.initial();
  GameReviewModel _review = GameReviewModel.empty();
  List<MoveTimelineEntry> _timeline = const [];
  Timer? _playTimer;

  ReplayProvider({
    ReplayEngine replayEngine = const ReplayEngine(),
    MoveTimelineEngine timelineEngine = const MoveTimelineEngine(),
    PostGameAnalysisEngine analysisEngine = const PostGameAnalysisEngine(),
  })  : _replayEngine = replayEngine,
        _timelineEngine = timelineEngine,
        _analysisEngine = analysisEngine;

  ReplayStateModel get state => _state;
  GameReviewModel get review => _review;
  List<MoveTimelineEntry> get timeline => List.unmodifiable(_timeline);

  void loadFromGame({
    required AppModel appModel,
    required List<MoveReviewModel> reviews,
  }) {
    pause();
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final moves = _replayEngine.movesFromMetas(appModel.moveMetaList);
      final moveMetas = _replayEngine.buildMoveMetas(moves);
      final reviewedEvaluations = _timelineEngine.evaluations(
        moves: moves,
        reviews: reviews,
      );
      final evaluations = reviews.isEmpty
          ? _replayEngine.evaluationsForMoves(moves)
          : reviewedEvaluations;
      _timeline = _timelineEngine.build(moves: moves, reviews: reviews);
      _review = _analysisEngine.analyze(
        moveCount: moves.length,
        reviews: reviews,
        evaluations: evaluations,
      );
      _state = ReplayStateModel(
        board: _replayEngine.boardAt(moves: moves, moveIndex: moves.length),
        moves: moves,
        moveMetas: moveMetas,
        reviews: reviews,
        currentMoveIndex: moves.length,
        isPlaying: false,
        playbackSpeed: _state.playbackSpeed,
        isLoading: false,
        errorMessage: null,
      );
    } on Object {
      _state = _state.copyWith(
        isLoading: false,
        isPlaying: false,
        errorMessage: 'Could not prepare the game replay.',
      );
      _timeline = const [];
      _review = GameReviewModel.empty();
    }
    notifyListeners();
  }

  void jumpToMove(int moveIndex) {
    final safeIndex = moveIndex.clamp(0, _state.moves.length).toInt();
    _state = _state.copyWith(
      board: _replayEngine.boardAt(
        moves: _state.moves,
        moveIndex: safeIndex,
      ),
      currentMoveIndex: safeIndex,
      errorMessage: null,
    );
    notifyListeners();
  }

  void nextMove() {
    if (!_state.canGoNext) {
      pause();
      return;
    }
    jumpToMove(_state.currentMoveIndex + 1);
  }

  void previousMove() {
    if (!_state.canGoPrevious) return;
    jumpToMove(_state.currentMoveIndex - 1);
  }

  void goToStart() {
    jumpToMove(0);
  }

  void goToEnd() {
    jumpToMove(_state.moves.length);
  }

  void play() {
    if (_state.moves.isEmpty) return;
    if (!_state.canGoNext) jumpToMove(0);
    _state = _state.copyWith(isPlaying: true);
    notifyListeners();
    _restartTimer();
  }

  void pause() {
    _playTimer?.cancel();
    _playTimer = null;
    if (_state.isPlaying) {
      _state = _state.copyWith(isPlaying: false);
      notifyListeners();
    }
  }

  void togglePlayback() {
    _state.isPlaying ? pause() : play();
  }

  void setPlaybackSpeed(double speed) {
    final safeSpeed = speed.clamp(0.5, 3.0).toDouble();
    _state = _state.copyWith(playbackSpeed: safeSpeed);
    notifyListeners();
    if (_state.isPlaying) _restartTimer();
  }

  void _restartTimer() {
    _playTimer?.cancel();
    final intervalMs = (900 / _state.playbackSpeed).round();
    _playTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) => nextMove(),
    );
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }
}
