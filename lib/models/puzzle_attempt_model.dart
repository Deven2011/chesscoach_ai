import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's attempt at solving a puzzle
class PuzzleAttemptModel {
  final String id;
  final String userId;
  final String puzzleId;
  final DateTime attemptedAt;
  final bool completed;
  final bool correct;
  final Duration solvingTime; // Time taken to solve
  final List<String> moveSequence; // Moves made by user
  final int hintsUsed; // Number of hints used
  final int xpEarned; // XP earned from this attempt
  final int streakBonus; // Streak bonus XP (if any)
  final String? feedback; // Feedback on the attempt

  const PuzzleAttemptModel({
    required this.id,
    required this.userId,
    required this.puzzleId,
    required this.attemptedAt,
    required this.completed,
    required this.correct,
    required this.solvingTime,
    required this.moveSequence,
    required this.hintsUsed,
    required this.xpEarned,
    required this.streakBonus,
    this.feedback,
  });

  factory PuzzleAttemptModel.fromMap(Map<String, dynamic> map) {
    return PuzzleAttemptModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      puzzleId: map['puzzleId'] as String? ?? '',
      attemptedAt: map['attemptedAt'] is Timestamp
          ? (map['attemptedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['attemptedAt'] as String? ?? '') ?? DateTime.now(),
      completed: map['completed'] as bool? ?? false,
      correct: map['correct'] as bool? ?? false,
      solvingTime: Duration(seconds: map['solvingTimeSeconds'] as int? ?? 0),
      moveSequence: List<String>.from(map['moveSequence'] as List? ?? []),
      hintsUsed: map['hintsUsed'] as int? ?? 0,
      xpEarned: map['xpEarned'] as int? ?? 0,
      streakBonus: map['streakBonus'] as int? ?? 0,
      feedback: map['feedback'] as String?,
    );
  }

  factory PuzzleAttemptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PuzzleAttemptModel.fromMap({...data, 'id': doc.id});
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'puzzleId': puzzleId,
      'attemptedAt': attemptedAt,
      'completed': completed,
      'correct': correct,
      'solvingTimeSeconds': solvingTime.inSeconds,
      'moveSequence': moveSequence,
      'hintsUsed': hintsUsed,
      'xpEarned': xpEarned,
      'streakBonus': streakBonus,
      'feedback': feedback,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'puzzleId': puzzleId,
      'attemptedAt': Timestamp.fromDate(attemptedAt),
      'completed': completed,
      'correct': correct,
      'solvingTimeSeconds': solvingTime.inSeconds,
      'moveSequence': moveSequence,
      'hintsUsed': hintsUsed,
      'xpEarned': xpEarned,
      'streakBonus': streakBonus,
      'feedback': feedback,
    };
  }

  PuzzleAttemptModel copyWith({
    String? id,
    String? userId,
    String? puzzleId,
    DateTime? attemptedAt,
    bool? completed,
    bool? correct,
    Duration? solvingTime,
    List<String>? moveSequence,
    int? hintsUsed,
    int? xpEarned,
    int? streakBonus,
    String? feedback,
  }) {
    return PuzzleAttemptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      puzzleId: puzzleId ?? this.puzzleId,
      attemptedAt: attemptedAt ?? this.attemptedAt,
      completed: completed ?? this.completed,
      correct: correct ?? this.correct,
      solvingTime: solvingTime ?? this.solvingTime,
      moveSequence: moveSequence ?? this.moveSequence,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      xpEarned: xpEarned ?? this.xpEarned,
      streakBonus: streakBonus ?? this.streakBonus,
      feedback: feedback ?? this.feedback,
    );
  }
}
