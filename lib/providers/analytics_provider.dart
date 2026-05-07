import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:en_passant/firebase/firestore_service.dart';
import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/models/match_model.dart';
import 'package:en_passant/models/sync_state_model.dart';
import 'package:en_passant/services/offline_cache_service.dart';
import 'package:en_passant/services/sync_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final OfflineCacheService _cacheService;
  final SyncService _syncService;

  AnalyticsModel _analytics = AnalyticsModel.empty();
  bool _isLoading = false;
  String? _errorMessage;
  String? _activeUserId;
  String? _lastMatchSignature;

  AnalyticsProvider({
    FirestoreService? firestoreService,
    OfflineCacheService? cacheService,
    SyncService? syncService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _cacheService = cacheService ?? OfflineCacheService(),
        _syncService = syncService ?? SyncService();

  AnalyticsModel get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void bindUser(String? userId, List<MatchModel> matches) {
    final signature = _signature(userId, matches);
    if (_activeUserId == userId && _lastMatchSignature == signature) return;
    _activeUserId = userId;
    _lastMatchSignature = signature;
    _analytics = AnalyticsModel.fromMatches(matches);
    unawaited(_loadCachedAnalyticsIfNeeded(userId));
    _saveSummary();
    scheduleMicrotask(notifyListeners);
  }

  void updateFromMatches(List<MatchModel> matches) {
    _analytics = AnalyticsModel.fromMatches(matches);
    unawaited(_cacheActiveAnalytics());
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
      await _cacheService.saveAnalytics(userId, _analytics);
      await _firestoreService.saveAnalyticsSummary(
        userId: userId,
        analytics: _analytics,
      );
    } on Object {
      final cached = await _cacheService.getAnalytics(userId);
      if (cached != null) {
        _analytics = cached;
        _errorMessage = 'Showing cached analytics.';
      } else {
        _errorMessage = 'Could not refresh analytics.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSummary() async {
    final userId = _activeUserId;
    if (userId == null) return;
    await _cacheService.saveAnalytics(userId, _analytics);
    try {
      await _firestoreService.saveAnalyticsSummary(
        userId: userId,
        analytics: _analytics,
      );
    } on Object {
      await _syncService.enqueue(
        SyncActionModel.create(
          type: SyncActionType.saveAnalytics,
          userId: userId,
          payload: _analytics.toMap(),
        ),
      );
    }
  }

  Future<void> _cacheActiveAnalytics() async {
    final userId = _activeUserId;
    if (userId == null) return;
    await _cacheService.saveAnalytics(userId, _analytics);
  }

  Future<void> _loadCachedAnalyticsIfNeeded(String? userId) async {
    if (userId == null || _analytics.totalMatches > 0) return;
    final cached = await _cacheService.getAnalytics(userId);
    if (cached == null) return;
    _analytics = cached;
    _errorMessage = 'Showing cached analytics.';
    notifyListeners();
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
