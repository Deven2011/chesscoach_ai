import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:en_passant/models/sync_state_model.dart';
import 'package:en_passant/services/connectivity_service.dart';
import 'package:en_passant/services/sync_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  StreamSubscription<ConnectivitySnapshot>? _connectivitySubscription;
  StreamSubscription<SyncStateModel>? _syncSubscription;
  ConnectivitySnapshot _snapshot = ConnectivitySnapshot.offline();
  SyncStateModel _syncState = SyncStateModel.idle();
  bool _initialized = false;

  ConnectivityProvider({
    ConnectivityService? connectivityService,
    SyncService? syncService,
  })  : _connectivityService = connectivityService ?? ConnectivityService(),
        _syncService = syncService ?? SyncService() {
    _connectivitySubscription = _connectivityService.snapshots.listen(
      _handleConnectivityChange,
    );
    _syncSubscription = _syncService.stream.listen((state) {
      _syncState = state;
      notifyListeners();
    });
    unawaited(initialize());
  }

  ConnectivitySnapshot get snapshot => _snapshot;
  SyncStateModel get syncState => _syncState;
  bool get isOnline => _snapshot.isOnline;
  bool get isOffline => !_snapshot.isOnline;
  String get connectionLabel => _snapshot.label;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _connectivityService.start();
    _snapshot = _connectivityService.current;
    await _syncService.syncPending(isOnline: _snapshot.isOnline);
    notifyListeners();
  }

  Future<void> retrySync() async {
    final latest = await _connectivityService.checkNow();
    _snapshot = latest;
    await _syncService.syncPending(isOnline: latest.isOnline);
    notifyListeners();
  }

  void _handleConnectivityChange(ConnectivitySnapshot snapshot) {
    final wasOffline = !_snapshot.isOnline;
    _snapshot = snapshot;
    notifyListeners();

    if (snapshot.isOnline && wasOffline) {
      unawaited(_syncService.syncPending(isOnline: true));
    } else if (!snapshot.isOnline) {
      unawaited(_syncService.syncPending(isOnline: false));
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncSubscription?.cancel();
    _connectivityService.dispose();
    _syncService.dispose();
    super.dispose();
  }
}
