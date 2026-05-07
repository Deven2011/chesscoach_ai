import 'dart:async';

import 'package:en_passant/firebase/firestore_service.dart';
import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/models/coach_insight_model.dart';
import 'package:en_passant/models/match_model.dart';
import 'package:en_passant/models/puzzle_attempt_model.dart';
import 'package:en_passant/models/puzzle_progress_model.dart';
import 'package:en_passant/models/sync_state_model.dart';
import 'package:en_passant/models/user_model.dart';
import 'package:en_passant/services/offline_cache_service.dart';

class SyncService {
  static final SyncService _shared = SyncService._internal();

  final OfflineCacheService _cacheService;
  final FirestoreService _firestoreService;
  final StreamController<SyncStateModel> _controller =
      StreamController<SyncStateModel>.broadcast();

  bool _isSyncing = false;
  SyncStateModel _state = SyncStateModel.idle();

  factory SyncService({
    OfflineCacheService? cacheService,
    FirestoreService? firestoreService,
  }) {
    if (cacheService == null && firestoreService == null) {
      return _shared;
    }
    return SyncService._internal(
      cacheService: cacheService,
      firestoreService: firestoreService,
    );
  }

  SyncService._internal({
    OfflineCacheService? cacheService,
    FirestoreService? firestoreService,
  })  : _cacheService = cacheService ?? OfflineCacheService(),
        _firestoreService = firestoreService ?? FirestoreService();

  Stream<SyncStateModel> get stream => _controller.stream;
  SyncStateModel get state => _state;

  Future<void> enqueue(SyncActionModel action) async {
    await _cacheService.enqueueSyncAction(action);
    final count = (await _cacheService.getSyncQueue()).length;
    _emit(_state.copyWith(
      status: SyncQueueStatus.waiting,
      pendingCount: count,
      message: 'Changes will sync automatically.',
    ));
  }

  Future<void> syncPending({bool isOnline = true}) async {
    if (_isSyncing) return;

    var queue = await _cacheService.getSyncQueue();
    if (queue.isEmpty) {
      _emit(_state.copyWith(
        status: SyncQueueStatus.synced,
        pendingCount: 0,
        lastSyncedAt: DateTime.now(),
        message: 'All changes synced.',
      ));
      return;
    }

    if (!isOnline) {
      _emit(_state.copyWith(
        status: SyncQueueStatus.waiting,
        pendingCount: queue.length,
        message: 'Waiting for internet connection...',
      ));
      return;
    }

    _isSyncing = true;
    _emit(_state.copyWith(
      status: SyncQueueStatus.syncing,
      pendingCount: queue.length,
      message: 'Syncing offline changes...',
    ));

    final remaining = <SyncActionModel>[];
    for (final action in queue) {
      try {
        await _perform(action);
      } on Object catch (error) {
        remaining.add(action.markFailed(error));
      }
    }

    await _cacheService.saveSyncQueue(remaining);
    queue = remaining;
    _isSyncing = false;

    _emit(SyncStateModel(
      status: queue.isEmpty ? SyncQueueStatus.synced : SyncQueueStatus.failed,
      pendingCount: queue.length,
      lastSyncedAt: queue.isEmpty ? DateTime.now() : _state.lastSyncedAt,
      message: queue.isEmpty
          ? 'All changes synced.'
          : 'Some changes could not sync. Retry when online.',
    ));
  }

  Future<void> _perform(SyncActionModel action) async {
    switch (action.type) {
      case SyncActionType.saveMatch:
        await _firestoreService.saveMatch(MatchModel.fromMap(action.payload));
        break;
      case SyncActionType.saveAnalytics:
        await _firestoreService.saveAnalyticsSummary(
          userId: action.userId,
          analytics: AnalyticsModel.fromMap(action.payload),
        );
        break;
      case SyncActionType.savePuzzleAttempt:
        await _firestoreService.savePuzzleAttempt(
          action.userId,
          PuzzleAttemptModel.fromMap(action.payload),
        );
        break;
      case SyncActionType.savePuzzleProgress:
        await _firestoreService.savePuzzleProgress(
          userId: action.userId,
          progress: PuzzleProgressModel.fromMap(action.payload),
        );
        break;
      case SyncActionType.saveUserProfile:
        await _firestoreService.createOrUpdateUser(
          UserModel.fromMap(action.payload),
        );
        break;
      case SyncActionType.saveCoachInsights:
        await _firestoreService.saveCoachInsights(
          userId: action.userId,
          insights: (action.payload['insights'] as List<dynamic>? ?? [])
              .whereType<Map>()
              .map((item) => CoachInsightModel.fromMap(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(),
        );
        break;
    }
  }

  void _emit(SyncStateModel next) {
    _state = next;
    _controller.add(next);
  }

  void dispose() {
    _controller.close();
  }
}
