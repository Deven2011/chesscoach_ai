import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/models/coach_insight_model.dart';
import 'package:en_passant/models/match_model.dart';
import 'package:en_passant/models/puzzle_progress_model.dart';
import 'package:en_passant/models/sync_state_model.dart';
import 'package:en_passant/models/user_model.dart';

class OfflineCacheService {
  static const _matchesPrefix = 'offline.matches.';
  static const _analyticsPrefix = 'offline.analytics.';
  static const _profilePrefix = 'offline.profile.';
  static const _puzzleProgressPrefix = 'offline.puzzleProgress.';
  static const _coachInsightsPrefix = 'offline.coachInsights.';
  static const _replayPrefix = 'offline.replay.';
  static const _syncQueueKey = 'offline.syncQueue';
  static const _updatedAtSuffix = '.updatedAt';

  Future<void> saveMatches(String userId, List<MatchModel> matches) async {
    await _writeJsonList(
      '$_matchesPrefix$userId',
      matches.map((match) => match.toMap()).toList(),
    );
  }

  Future<List<MatchModel>> getMatches(String userId) async {
    final list = await _readJsonList('$_matchesPrefix$userId');
    return list.map(MatchModel.fromMap).toList();
  }

  Future<void> saveAnalytics(String userId, AnalyticsModel analytics) async {
    await _writeJson('$_analyticsPrefix$userId', analytics.toMap());
  }

  Future<AnalyticsModel?> getAnalytics(String userId) async {
    final map = await _readJson('$_analyticsPrefix$userId');
    if (map == null) return null;
    return AnalyticsModel.fromMap(map);
  }

  Future<void> saveUserProfile(UserModel user) async {
    await _writeJson('$_profilePrefix${user.uid}', user.toMap());
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final map = await _readJson('$_profilePrefix$userId');
    if (map == null) return null;
    return UserModel.fromMap(map);
  }

  Future<void> savePuzzleProgress(
    String userId,
    PuzzleProgressModel progress,
  ) async {
    await _writeJson('$_puzzleProgressPrefix$userId', progress.toMap());
  }

  Future<PuzzleProgressModel?> getPuzzleProgress(String userId) async {
    final map = await _readJson('$_puzzleProgressPrefix$userId');
    if (map == null) return null;
    return PuzzleProgressModel.fromMap(map);
  }

  Future<void> saveCoachInsights(
    String userId,
    List<CoachInsightModel> insights,
  ) async {
    await _writeJsonList(
      '$_coachInsightsPrefix$userId',
      insights.map((insight) => insight.toMap()).toList(),
    );
  }

  Future<List<CoachInsightModel>> getCoachInsights(String userId) async {
    final list = await _readJsonList('$_coachInsightsPrefix$userId');
    return list.map(CoachInsightModel.fromMap).toList();
  }

  Future<void> saveReplayData(
    String userId,
    List<Map<String, dynamic>> replayData,
  ) async {
    await _writeJsonList('$_replayPrefix$userId', replayData);
  }

  Future<List<Map<String, dynamic>>> getReplayData(String userId) async {
    return _readJsonList('$_replayPrefix$userId');
  }

  Future<void> enqueueSyncAction(SyncActionModel action) async {
    final queue = await getSyncQueue();
    if (queue.any((item) => item.id == action.id)) return;
    queue.add(action);
    await saveSyncQueue(queue);
  }

  Future<List<SyncActionModel>> getSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_syncQueueKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((item) => SyncActionModel.fromMap(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on Object {
      return [];
    }
  }

  Future<void> saveSyncQueue(List<SyncActionModel> queue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _syncQueueKey,
      jsonEncode(queue.map((action) => action.toMap()).toList()),
    );
  }

  Future<DateTime?> updatedAt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return DateTime.tryParse(prefs.getString('$key$_updatedAtSuffix') ?? '');
  }

  Future<void> _writeJson(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
    await prefs.setString(
      '$key$_updatedAtSuffix',
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> _writeJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
    await prefs.setString(
      '$key$_updatedAtSuffix',
      DateTime.now().toIso8601String(),
    );
  }

  Future<Map<String, dynamic>?> _readJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } on Object {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _readJsonList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on Object {
      return [];
    }
  }
}
