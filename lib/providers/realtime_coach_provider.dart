import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:en_passant/ai_coach/realtime_coach_engine.dart';
import 'package:en_passant/models/move_review_model.dart';

class RealtimeCoachProvider extends ChangeNotifier {
  final RealtimeCoachEngine _coachEngine;

  final List<MoveReviewModel> _reviews = [];
  bool _coachModeEnabled = false;
  bool _isAnalyzing = false;
  String? _errorMessage;
  MoveReviewModel? _latestReview;
  MoveReviewModel? _overlayReview;
  CoachGameSummary _summary = CoachGameSummary.empty();
  int _analysisToken = 0;
  bool _isGameReviewComplete = false;

  RealtimeCoachProvider({
    RealtimeCoachEngine coachEngine = const RealtimeCoachEngine(),
  }) : _coachEngine = coachEngine;

  List<MoveReviewModel> get reviews => List.unmodifiable(_reviews);
  bool get coachModeEnabled => _coachModeEnabled;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  MoveReviewModel? get latestReview => _latestReview;
  MoveReviewModel? get overlayReview => _overlayReview;
  CoachGameSummary get summary => _summary;
  int get mistakeCount =>
      _reviews.where((review) => review.quality == MoveQuality.mistake).length;
  int get blunderCount =>
      _reviews.where((review) => review.quality == MoveQuality.blunder).length;
  int get accuracy => _summary.accuracy;
  int get bestMoveStreak => _summary.bestMoveStreak;
  double get normalizedEvaluation {
    final eval = _latestReview?.afterEval ?? 0;
    return ((eval + 900) / 1800).clamp(0.05, 0.95).toDouble();
  }

  void startGame({required bool enabled}) {
    _reviews.clear();
    _coachModeEnabled = enabled;
    _isAnalyzing = false;
    _errorMessage = null;
    _latestReview = null;
    _overlayReview = null;
    _summary = CoachGameSummary.empty();
    _analysisToken++;
    _isGameReviewComplete = false;
    notifyListeners();
  }

  void setCoachModeEnabled(bool enabled) {
    if (_coachModeEnabled == enabled) return;
    _coachModeEnabled = enabled;
    notifyListeners();
  }

  Future<void> analyzeMove(MoveAnalysisInput input) async {
    if (!_coachModeEnabled) return;
    final token = ++_analysisToken;
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final review = await _coachEngine.analyzeMove(input);
      if (token != _analysisToken) return;
      _reviews.add(review);
      _latestReview = review;
      _summary = _coachEngine.summarize(_reviews);
      if (_shouldShowOverlay(review)) {
        _overlayReview = review;
        _clearOverlayLater(review.id);
      }
    } on Object {
      if (token == _analysisToken) {
        _errorMessage = 'Coach analysis could not finish for this move.';
      }
    } finally {
      if (token == _analysisToken) {
        _isAnalyzing = false;
        notifyListeners();
      }
    }
  }

  void completeGameReview() {
    if (_isGameReviewComplete) return;
    _isGameReviewComplete = true;
    _summary = _coachEngine.summarize(_reviews);
    notifyListeners();
  }

  void clearOverlay() {
    if (_overlayReview == null) return;
    _overlayReview = null;
    notifyListeners();
  }

  bool _shouldShowOverlay(MoveReviewModel review) {
    return review.quality == MoveQuality.brilliant ||
        review.quality == MoveQuality.great ||
        review.quality == MoveQuality.blunder ||
        review.quality == MoveQuality.mistake;
  }

  void _clearOverlayLater(String reviewId) {
    Timer(const Duration(seconds: 2), () {
      if (_overlayReview?.id != reviewId) return;
      _overlayReview = null;
      notifyListeners();
    });
  }
}
