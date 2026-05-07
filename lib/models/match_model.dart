import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchResult { win, loss, draw }

class MatchModel {
  final String id;
  final String userId;
  final String winner;
  final String gameMode;
  final int aiDifficulty;
  final Duration duration;
  final int moveCount;
  final DateTime timestamp;
  final String playerColor;
  final MatchResult result;
  final String openingFamily;
  final String lossPhase;
  final double aggressionScore;
  final double defenseScore;
  final double averageMoveSeconds;
  final List<String> moveHistory;

  const MatchModel({
    required this.id,
    required this.userId,
    required this.winner,
    required this.gameMode,
    required this.aiDifficulty,
    required this.duration,
    required this.moveCount,
    required this.timestamp,
    required this.playerColor,
    required this.result,
    this.openingFamily = 'Unclassified',
    this.lossPhase = '',
    this.aggressionScore = 0,
    this.defenseScore = 0,
    this.averageMoveSeconds = 0,
    this.moveHistory = const [],
  });

  factory MatchModel.completed({
    required String userId,
    required String winner,
    required String gameMode,
    required int aiDifficulty,
    required Duration duration,
    required int moveCount,
    required String playerColor,
    required MatchResult result,
    String openingFamily = 'Unclassified',
    String lossPhase = '',
    double aggressionScore = 0,
    double defenseScore = 0,
    double averageMoveSeconds = 0,
    List<String> moveHistory = const [],
  }) {
    return MatchModel(
      id: '',
      userId: userId,
      winner: winner,
      gameMode: gameMode,
      aiDifficulty: aiDifficulty,
      duration: duration,
      moveCount: moveCount,
      timestamp: DateTime.now(),
      playerColor: playerColor,
      result: result,
      openingFamily: openingFamily,
      lossPhase: lossPhase,
      aggressionScore: aggressionScore,
      defenseScore: defenseScore,
      averageMoveSeconds: averageMoveSeconds,
      moveHistory: moveHistory,
    );
  }

  factory MatchModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return MatchModel.fromMap({...data, 'id': snapshot.id});
  }

  factory MatchModel.fromMap(Map<String, dynamic> data) {
    return MatchModel(
      id: data['id'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      winner: data['winner'] as String? ?? 'Unknown',
      gameMode: data['gameMode'] as String? ?? 'Play vs AI',
      aiDifficulty: data['aiDifficulty'] as int? ?? 0,
      duration: Duration(seconds: data['durationSeconds'] as int? ?? 0),
      moveCount: data['moveCount'] as int? ?? 0,
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(data['timestamp'] as String? ?? '') ??
              DateTime.now(),
      playerColor: data['playerColor'] as String? ?? 'White',
      result: _parseResult(data['result'] as String?),
      openingFamily: data['openingFamily'] as String? ?? 'Unclassified',
      lossPhase: data['lossPhase'] as String? ?? '',
      aggressionScore: (data['aggressionScore'] as num?)?.toDouble() ?? 0,
      defenseScore: (data['defenseScore'] as num?)?.toDouble() ?? 0,
      averageMoveSeconds: (data['averageMoveSeconds'] as num?)?.toDouble() ?? 0,
      moveHistory: (data['moveHistory'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'winner': winner,
      'gameMode': gameMode,
      'aiDifficulty': aiDifficulty,
      'durationSeconds': duration.inSeconds,
      'moveCount': moveCount,
      'timestamp': timestamp.toIso8601String(),
      'playerColor': playerColor,
      'result': result.name,
      'openingFamily': openingFamily,
      'lossPhase': lossPhase,
      'aggressionScore': aggressionScore,
      'defenseScore': defenseScore,
      'averageMoveSeconds': averageMoveSeconds,
      'moveHistory': moveHistory,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'winner': winner,
      'gameMode': gameMode,
      'aiDifficulty': aiDifficulty,
      'durationSeconds': duration.inSeconds,
      'moveCount': moveCount,
      'timestamp': Timestamp.fromDate(timestamp),
      'playerColor': playerColor,
      'result': result.name,
      'openingFamily': openingFamily,
      'lossPhase': lossPhase,
      'aggressionScore': aggressionScore,
      'defenseScore': defenseScore,
      'averageMoveSeconds': averageMoveSeconds,
      'moveHistory': moveHistory,
    };
  }

  MatchModel copyWith({String? id}) {
    return MatchModel(
      id: id ?? this.id,
      userId: userId,
      winner: winner,
      gameMode: gameMode,
      aiDifficulty: aiDifficulty,
      duration: duration,
      moveCount: moveCount,
      timestamp: timestamp,
      playerColor: playerColor,
      result: result,
      openingFamily: openingFamily,
      lossPhase: lossPhase,
      aggressionScore: aggressionScore,
      defenseScore: defenseScore,
      averageMoveSeconds: averageMoveSeconds,
      moveHistory: moveHistory,
    );
  }

  static MatchResult _parseResult(String? result) {
    return MatchResult.values.firstWhere(
      (value) => value.name == result,
      orElse: () => MatchResult.loss,
    );
  }
}
