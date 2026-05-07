import 'dart:async';
import 'dart:io';

enum AppConnectionType { wifi, mobile, ethernet, none, unknown }

class ConnectivitySnapshot {
  final bool isOnline;
  final AppConnectionType type;
  final DateTime checkedAt;

  const ConnectivitySnapshot({
    required this.isOnline,
    required this.type,
    required this.checkedAt,
  });

  factory ConnectivitySnapshot.offline() {
    return ConnectivitySnapshot(
      isOnline: false,
      type: AppConnectionType.none,
      checkedAt: DateTime.now(),
    );
  }

  String get label {
    switch (type) {
      case AppConnectionType.wifi:
        return 'Wi-Fi';
      case AppConnectionType.mobile:
        return 'mobile data';
      case AppConnectionType.ethernet:
        return 'ethernet';
      case AppConnectionType.none:
        return 'offline';
      case AppConnectionType.unknown:
        return 'online';
    }
  }
}

class ConnectivityService {
  ConnectivityService({
    this.checkInterval = const Duration(seconds: 8),
    this.lookupHost = 'firebase.google.com',
  });

  final Duration checkInterval;
  final String lookupHost;
  final StreamController<ConnectivitySnapshot> _controller =
      StreamController<ConnectivitySnapshot>.broadcast();
  Timer? _timer;
  ConnectivitySnapshot _lastSnapshot = ConnectivitySnapshot.offline();

  Stream<ConnectivitySnapshot> get snapshots => _controller.stream;
  ConnectivitySnapshot get current => _lastSnapshot;

  Future<void> start() async {
    await checkNow();
    _timer ??= Timer.periodic(checkInterval, (_) => unawaited(checkNow()));
  }

  Future<ConnectivitySnapshot> checkNow() async {
    final snapshot = await _buildSnapshot();
    if (snapshot.isOnline != _lastSnapshot.isOnline ||
        snapshot.type != _lastSnapshot.type) {
      _lastSnapshot = snapshot;
      _controller.add(snapshot);
    } else {
      _lastSnapshot = snapshot;
    }
    return snapshot;
  }

  Future<ConnectivitySnapshot> _buildSnapshot() async {
    try {
      final lookup = await InternetAddress.lookup(lookupHost)
          .timeout(const Duration(seconds: 3));
      final online = lookup.any((address) => address.rawAddress.isNotEmpty);
      if (!online) return ConnectivitySnapshot.offline();

      return ConnectivitySnapshot(
        isOnline: true,
        type: await _detectConnectionType(),
        checkedAt: DateTime.now(),
      );
    } on Object {
      return ConnectivitySnapshot.offline();
    }
  }

  Future<AppConnectionType> _detectConnectionType() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      final names = interfaces
          .map((interface) => interface.name.toLowerCase())
          .join(' ');

      if (names.contains('wlan') ||
          names.contains('wifi') ||
          names.contains('wi-fi') ||
          names.contains('en0')) {
        return AppConnectionType.wifi;
      }
      if (names.contains('rmnet') ||
          names.contains('cell') ||
          names.contains('mobile') ||
          names.contains('wwan') ||
          names.contains('ccmni')) {
        return AppConnectionType.mobile;
      }
      if (names.contains('eth')) return AppConnectionType.ethernet;
      return AppConnectionType.unknown;
    } on Object {
      return AppConnectionType.unknown;
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
