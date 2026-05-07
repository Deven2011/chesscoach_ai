import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's puzzle solving progress and statistics
class PuzzleProgressModel {
  final String id;
  final String userId;
  final int totalPuzzlesSolved;
  final int correctSolutions;
  final double solveAccuracy; // Percentage (0-100)
  final Duration totalTimeSpent;
  final int currentStreak; // Current consecutive daily puzzles solved
  final int longestStreak; // Longest streak achieved
  final DateTime lastSolvedDate; // Date of last puzzle solved
  final DateTime? dailyPuzzleCompletedDate; // Date when daily puzzle was completed
  final int totalXpEarned;
  final Map<String, int> categoryStats; // Puzzle category -> solve count
  final Map<String, int> themeStats; // Tactical theme -> solve count
  final Map<String, int> difficultyStats; // Difficulty level -> solve count
  final int hintsUsed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<int> recentPuzzleRatings; // Last 10 puzzle ratings
  final int averageSolveTime; // Average solve time in seconds

  const PuzzleProgressModel({
    required this.id,
    required this.userId,
    required this.totalPuzzlesSolved,
    required this.correctSolutions,
    required this.solveAccuracy,
    required this.totalTimeSpent,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastSolvedDate,
    this.dailyPuzzleCompletedDate,
    required this.totalXpEarned,
    required this.categoryStats,
    required this.themeStats,
    required this.difficultyStats,
    required this.hintsUsed,
    required this.createdAt,
    required this.updatedAt,
    required this.recentPuzzleRatings,
    required this.averageSolveTime,
  });

  factory PuzzleProgressModel.empty(String userId) {
    return PuzzleProgressModel(
      id: '',
      userId: userId,
      totalPuzzlesSolved: 0,
      correctSolutions: 0,
      solveAccuracy: 0.0,
      totalTimeSpent: Duration.zero,
      currentStreak: 0,
      longestStreak: 0,
      lastSolvedDate: DateTime.now(),
      dailyPuzzleCompletedDate: null,
      totalXpEarned: 0,
      categoryStats: {},
      themeStats: {},
      difficultyStats: {},
      hintsUsed: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      recentPuzzleRatings: [],
      averageSolveTime: 0,
    );
  }

  factory PuzzleProgressModel.fromMap(Map<String, dynamic> map) {
    return PuzzleProgressModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      totalPuzzlesSolved: map['totalPuzzlesSolved'] as int? ?? 0,
      correctSolutions: map['correctSolutions'] as int? ?? 0,
      solveAccuracy: (map['solveAccuracy'] as num?)?.toDouble() ?? 0.0,
      totalTimeSpent: Duration(seconds: map['totalTimeSpentSeconds'] as int? ?? 0),
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastSolvedDate: map['lastSolvedDate'] is Timestamp
          ? (map['lastSolvedDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['lastSolvedDate'] as String? ?? '') ?? DateTime.now(),
      dailyPuzzleCompletedDate: map['dailyPuzzleCompletedDate'] is Timestamp
          ? (map['dailyPuzzleCompletedDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['dailyPuzzleCompletedDate'] as String? ?? ''),
      totalXpEarned: map['totalXpEarned'] as int? ?? 0,
      categoryStats: Map<String, int>.from(map['categoryStats'] as Map? ?? {}),
      themeStats: Map<String, int>.from(map['themeStats'] as Map? ?? {}),
      difficultyStats: Map<String, int>.from(map['difficultyStats'] as Map? ?? {}),
      hintsUsed: map['hintsUsed'] as int? ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      recentPuzzleRatings: List<int>.from(map['recentPuzzleRatings'] as List? ?? []),
      averageSolveTime: map['averageSolveTime'] as int? ?? 0,
    );
  }

  factory PuzzleProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PuzzleProgressModel.fromMap({...data, 'id': doc.id});
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'totalPuzzlesSolved': totalPuzzlesSolved,
      'correctSolutions': correctSolutions,
      'solveAccuracy': solveAccuracy,
      'totalTimeSpentSeconds': totalTimeSpent.inSeconds,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastSolvedDate': lastSolvedDate,
      'dailyPuzzleCompletedDate': dailyPuzzleCompletedDate,
      'totalXpEarned': totalXpEarned,
      'categoryStats': categoryStats,
      'themeStats': themeStats,
      'difficultyStats': difficultyStats,
      'hintsUsed': hintsUsed,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'recentPuzzleRatings': recentPuzzleRatings,
      'averageSolveTime': averageSolveTime,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'totalPuzzlesSolved': totalPuzzlesSolved,
      'correctSolutions': correctSolutions,
      'solveAccuracy': solveAccuracy,
      'totalTimeSpentSeconds': totalTimeSpent.inSeconds,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastSolvedDate': Timestamp.fromDate(lastSolvedDate),
      'dailyPuzzleCompletedDate': dailyPuzzleCompletedDate != null
          ? Timestamp.fromDate(dailyPuzzleCompletedDate!)
          : null,
      'totalXpEarned': totalXpEarned,
      'categoryStats': categoryStats,
      'themeStats': themeStats,
      'difficultyStats': difficultyStats,
      'hintsUsed': hintsUsed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'recentPuzzleRatings': recentPuzzleRatings,
      'averageSolveTime': averageSolveTime,
    };
  }

  PuzzleProgressModel copyWith({
    String? id,
    String? userId,
    int? totalPuzzlesSolved,
    int? correctSolutions,
    double? solveAccuracy,
    Duration? totalTimeSpent,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSolvedDate,
    DateTime? dailyPuzzleCompletedDate,
    int? totalXpEarned,
    Map<String, int>? categoryStats,
    Map<String, int>? themeStats,
    Map<String, int>? difficultyStats,
    int? hintsUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<int>? recentPuzzleRatings,
    int? averageSolveTime,
  }) {
    return PuzzleProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalPuzzlesSolved: totalPuzzlesSolved ?? this.totalPuzzlesSolved,
      correctSolutions: correctSolutions ?? this.correctSolutions,
      solveAccuracy: solveAccuracy ?? this.solveAccuracy,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSolvedDate: lastSolvedDate ?? this.lastSolvedDate,
      dailyPuzzleCompletedDate: dailyPuzzleCompletedDate ?? this.dailyPuzzleCompletedDate,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      categoryStats: categoryStats ?? this.categoryStats,
      themeStats: themeStats ?? this.themeStats,
      difficultyStats: difficultyStats ?? this.difficultyStats,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recentPuzzleRatings: recentPuzzleRatings ?? this.recentPuzzleRatings,
      averageSolveTime: averageSolveTime ?? this.averageSolveTime,
    );
  }

  bool hasCompletedDailyPuzzleToday() {
    if (dailyPuzzleCompletedDate == null) return false;
    final today = DateTime.now();
    final completed = dailyPuzzleCompletedDate!;
    return today.year == completed.year &&
        today.month == completed.month &&
        today.day == completed.day;
  }
}
