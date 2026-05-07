import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:en_passant/firebase/firestore_service.dart';
import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/models/match_model.dart';

class AnalyticsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  AnalyticsModel _analytics = AnalyticsModel.empty();
  bool _isLoading = false;
  String? _errorMessage;
  String? _activeUserId;
  String? _lastMatchSignature;

  AnalyticsProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  AnalyticsModel get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void bindUser(String? userId, List<MatchModel> matches) {
    final signature = _signature(userId, matches);
    if (_activeUserId == userId && _lastMatchSignature == signature) return;
    _activeUserId = userId;
    _lastMatchSignature = signature;
    _analytics = AnalyticsModel.fromMatches(matches);
    _saveSummary();
    scheduleMicrotask(notifyListeners);
  }

  void updateFromMatches(List<MatchModel> matches) {
    _analytics = AnalyticsModel.fromMatches(matches);
    notifyListeners();
    _saveSummary();
  }

  Future<void> refresh() async {
    final userId = _activeUserId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      final matches = await _firestoreService.getMatchHistory(userId);
      _analytics = AnalyticsModel.fromMatches(matches);
      _errorMessage = null;
      await _firestoreService.saveAnalyticsSummary(
        userId: userId,
        analytics: _analytics,
      );
    } on Object {
      _errorMessage = 'Could not refresh analytics.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSummary() async {
    final userId = _activeUserId;
    if (userId == null) return;
    try {
      await _firestoreService.saveAnalyticsSummary(
        userId: userId,
        analytics: _analytics,
      );
    } on Object {
      // Local analytics stay available even if summary persistence fails.
    }
  }

  String _signature(String? userId, List<MatchModel> matches) {
    return [
      userId ?? '',
      matches.length,
      ...matches.take(12).map((match) {
        return '${match.id}:${match.timestamp.millisecondsSinceEpoch}:${match.result.name}';
      }),
    ].join('|');
  }
}
