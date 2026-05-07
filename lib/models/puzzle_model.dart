import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a chess puzzle with tactical themes
class PuzzleModel {
  final String id;
  final String fen; // Forsyth–Edwards Notation for position
  final List<String> solution; // Correct move sequence in UCI notation
  final String theme; // Tactical theme (e.g., 'Checkmate in 1', 'Fork', 'Pin')
  final int difficulty; // 1-5 difficulty level
  final int rating; // Estimated skill level required
  final String description; // Tactical explanation
  final List<String> hints; // Optional move hints
  final String? videoUrl; // Optional tactical explanation video
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int attempts; // Number of times attempted by users
  final int solveCount; // Number of times solved correctly
  final double? averageSolveTime; // Average solve time in seconds
  final String category; // Category (e.g., 'Endgame', 'Opening', 'Middle Game')
  final int xpReward; // Base XP reward for solving
  final bool isDaily; // Whether this is a daily puzzle

  const PuzzleModel({
    required this.id,
    required this.fen,
    required this.solution,
    required this.theme,
    required this.difficulty,
    required this.rating,
    required this.description,
    required this.hints,
    this.videoUrl,
    required this.createdAt,
    this.updatedAt,
    required this.attempts,
    required this.solveCount,
    this.averageSolveTime,
    required this.category,
    required this.xpReward,
    required this.isDaily,
  });

  factory PuzzleModel.fromMap(Map<String, dynamic> map) {
    return PuzzleModel(
      id: map['id'] as String? ?? '',
      fen: map['fen'] as String? ?? '',
      solution: List<String>.from(map['solution'] as List? ?? []),
      theme: map['theme'] as String? ?? '',
      difficulty: map['difficulty'] as int? ?? 1,
      rating: map['rating'] as int? ?? 800,
      description: map['description'] as String? ?? '',
      hints: List<String>.from(map['hints'] as List? ?? []),
      videoUrl: map['videoUrl'] as String?,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt'] as String? ?? ''),
      attempts: map['attempts'] as int? ?? 0,
      solveCount: map['solveCount'] as int? ?? 0,
      averageSolveTime: (map['averageSolveTime'] as num?)?.toDouble(),
      category: map['category'] as String? ?? 'General',
      xpReward: map['xpReward'] as int? ?? 50,
      isDaily: map['isDaily'] as bool? ?? false,
    );
  }

  factory PuzzleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PuzzleModel.fromMap({...data, 'id': doc.id});
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fen': fen,
      'solution': solution,
      'theme': theme,
      'difficulty': difficulty,
      'rating': rating,
      'description': description,
      'hints': hints,
      'videoUrl': videoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'attempts': attempts,
      'solveCount': solveCount,
      'averageSolveTime': averageSolveTime,
      'category': category,
      'xpReward': xpReward,
      'isDaily': isDaily,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fen': fen,
      'solution': solution,
      'theme': theme,
      'difficulty': difficulty,
      'rating': rating,
      'description': description,
      'hints': hints,
      'videoUrl': videoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'attempts': attempts,
      'solveCount': solveCount,
      'averageSolveTime': averageSolveTime,
      'category': category,
      'xpReward': xpReward,
      'isDaily': isDaily,
    };
  }

  PuzzleModel copyWith({
    String? id,
    String? fen,
    List<String>? solution,
    String? theme,
    int? difficulty,
    int? rating,
    String? description,
    List<String>? hints,
    String? videoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? attempts,
    int? solveCount,
    double? averageSolveTime,
    String? category,
    int? xpReward,
    bool? isDaily,
  }) {
    return PuzzleModel(
      id: id ?? this.id,
      fen: fen ?? this.fen,
      solution: solution ?? this.solution,
      theme: theme ?? this.theme,
      difficulty: difficulty ?? this.difficulty,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      hints: hints ?? this.hints,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attempts: attempts ?? this.attempts,
      solveCount: solveCount ?? this.solveCount,
      averageSolveTime: averageSolveTime ?? this.averageSolveTime,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
      isDaily: isDaily ?? this.isDaily,
    );
  }
}
