enum SyncActionType {
  saveMatch,
  saveAnalytics,
  savePuzzleAttempt,
  savePuzzleProgress,
  saveUserProfile,
  saveCoachInsights,
}

enum SyncQueueStatus { idle, syncing, synced, waiting, failed }

class SyncActionModel {
  final String id;
  final SyncActionType type;
  final String userId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  const SyncActionModel({
    required this.id,
    required this.type,
    required this.userId,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  factory SyncActionModel.create({
    required SyncActionType type,
    required String userId,
    required Map<String, dynamic> payload,
  }) {
    final now = DateTime.now();
    return SyncActionModel(
      id: '${type.name}_${now.microsecondsSinceEpoch}',
      type: type,
      userId: userId,
      payload: payload,
      createdAt: now,
    );
  }

  factory SyncActionModel.fromMap(Map<String, dynamic> map) {
    return SyncActionModel(
      id: map['id'] as String? ?? '',
      type: SyncActionType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => SyncActionType.saveMatch,
      ),
      userId: map['userId'] as String? ?? '',
      payload: Map<String, dynamic>.from(map['payload'] as Map? ?? {}),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      attempts: map['attempts'] as int? ?? 0,
      lastError: map['lastError'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'userId': userId,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'attempts': attempts,
      'lastError': lastError,
    };
  }

  SyncActionModel markFailed(Object error) {
    return SyncActionModel(
      id: id,
      type: type,
      userId: userId,
      payload: payload,
      createdAt: createdAt,
      attempts: attempts + 1,
      lastError: error.toString(),
    );
  }
}

class SyncStateModel {
  final SyncQueueStatus status;
  final int pendingCount;
  final DateTime? lastSyncedAt;
  final String? message;

  const SyncStateModel({
    required this.status,
    required this.pendingCount,
    this.lastSyncedAt,
    this.message,
  });

  factory SyncStateModel.idle() {
    return const SyncStateModel(
      status: SyncQueueStatus.idle,
      pendingCount: 0,
    );
  }

  SyncStateModel copyWith({
    SyncQueueStatus? status,
    int? pendingCount,
    DateTime? lastSyncedAt,
    String? message,
  }) {
    return SyncStateModel(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message,
    );
  }
}
