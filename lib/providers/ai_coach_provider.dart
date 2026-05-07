import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:en_passant/ai_coach/ai_coach_engine.dart';
import 'package:en_passant/firebase/firestore_service.dart';
import 'package:en_passant/models/coach_insight_model.dart';
import 'package:en_passant/models/match_model.dart';

class AiCoachProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AiCoachEngine _coachEngine;

  AiCoachReport _report = AiCoachReport.empty();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasPendingSave = false;
  String? _errorMessage;
  String? _activeUserId;
  String? _lastMatchSignature;

  AiCoachProvider({
    FirestoreService? firestoreService,
    AiCoachEngine? coachEngine,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _coachEngine = coachEngine ?? AiCoachEngine();

  AiCoachReport get report => _report;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<CoachInsightModel> get insights => _report.insights;
  List<CoachInsightModel> get recommendations => _report.recommendations;
  List<CoachInsightModel> get strengths => _report.strengths;
  List<CoachInsightModel> get weaknesses => _report.weaknesses;
  List<CoachInsightModel> get tendencies => _report.tendencies;

  void bindUser(String? userId, List<MatchModel> matches) {
    final signature = _signature(userId, matches);
    if (_activeUserId == userId && _lastMatchSignature == signature) return;

    _activeUserId = userId;
    _lastMatchSignature = signature;
    _errorMessage = null;

    if (userId == null) {
      _report = AiCoachReport.empty();
      scheduleMicrotask(notifyListeners);
      return;
    }

    _report = _coachEngine.buildReport(matches);
    unawaited(_persistReport());
    scheduleMicrotask(notifyListeners);
  }

  Future<void> refresh() async {
    final userId = _activeUserId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      final matches = await _firestoreService.getMatchHistory(userId);
      _report = _coachEngine.buildReport(matches);
      _lastMatchSignature = _signature(userId, matches);
      await _firestoreService.saveCoachReport(userId: userId, report: _report);
      _errorMessage = null;
    } on Object {
      _errorMessage = 'Could not refresh AI Coach insights.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStoredInsights() async {
    final userId = _activeUserId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.getCoachInsights(userId);
      _errorMessage = null;
    } on Object {
      _errorMessage = 'Could not load stored coach insights.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistReport() async {
    final userId = _activeUserId;
    if (userId == null) return;
    if (_isSaving) {
      _hasPendingSave = true;
      return;
    }

    _isSaving = true;
    final reportToSave = _report;
    try {
      await _firestoreService.saveCoachReport(
        userId: userId,
        report: reportToSave,
      );
      _errorMessage = null;
    } on Object {
      _errorMessage = 'AI Coach is available locally, but sync failed.';
    } finally {
      _isSaving = false;
      notifyListeners();
      if (_hasPendingSave) {
        _hasPendingSave = false;
        unawaited(_persistReport());
      }
    }
  }

  String _signature(String? userId, List<MatchModel> matches) {
    return [
      userId ?? '',
      matches.length,
      ...matches.take(20).map((match) {
        return [
          match.id,
          match.timestamp.millisecondsSinceEpoch,
          match.result.name,
          match.openingFamily,
          match.aggressionScore.toStringAsFixed(2),
          match.defenseScore.toStringAsFixed(2),
        ].join(':');
      }),
    ].join('|');
  }
}
