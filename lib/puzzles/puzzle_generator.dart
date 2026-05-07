import 'package:en_passant/models/puzzle_model.dart';

/// Generator for creating and managing puzzle content
class PuzzleGenerator {
  // Sample puzzle database - in production, this would come from Firestore
  static final List<PuzzleModel> _samplePuzzles = [
    // Checkmate in 1 puzzles
    PuzzleModel(
      id: 'puzzle_001',
      fen: '8/8/8/8/8/5k2/5Q2/5K2 w - - 0 1',
      solution: ['f2f3'],
      theme: 'Checkmate in 1',
      difficulty: 1,
      rating: 800,
      description: 'Deliver checkmate with the queen to the exposed king.',
      hints: ['The king has limited escape squares', 'Look for a forcing move'],
      category: 'Checkmate',
      xpReward: 50,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 150,
      solveCount: 145,
    ),
    PuzzleModel(
      id: 'puzzle_002',
      fen: '7k/5Q2/6K1/8/8/8/8/8 w - - 0 1',
      solution: ['f7h7'],
      theme: 'Checkmate in 1',
      difficulty: 1,
      rating: 850,
      description: 'Use the queen to deliver checkmate.',
      hints: ['Find the back rank mate', 'The king cannot escape'],
      category: 'Checkmate',
      xpReward: 50,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 120,
      solveCount: 115,
    ),

    // Fork puzzles
    PuzzleModel(
      id: 'puzzle_003',
      fen: 'r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 1',
      solution: ['b5d6'],
      theme: 'Fork',
      difficulty: 2,
      rating: 1000,
      description: 'The knight fork attacks two pieces simultaneously - a classic tactical motif.',
      hints: ['Look for a move that attacks multiple pieces', 'The queen and king are vulnerable'],
      category: 'Tactics',
      xpReward: 75,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 200,
      solveCount: 185,
    ),

    // Pin puzzles
    PuzzleModel(
      id: 'puzzle_004',
      fen: '1r3r2/5k2/3b1p2/8/3B4/5Q2/4K3/8 w - - 0 1',
      solution: ['d4b6'],
      theme: 'Pin',
      difficulty: 2,
      rating: 1050,
      description: 'Identify the pinned piece and exploit it.',
      hints: ['One piece is pinned to its king', 'Capture the pinned piece'],
      category: 'Tactics',
      xpReward: 75,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 180,
      solveCount: 170,
    ),

    // Skewer puzzle
    PuzzleModel(
      id: 'puzzle_005',
      fen: '8/8/8/8/3r4/8/3Q4/3K4 w - - 0 1',
      solution: ['d2a5'],
      theme: 'Skewer',
      difficulty: 2,
      rating: 1100,
      description: 'A skewer forces a high-value piece to move and captures a lower-value piece behind it.',
      hints: ['Look for alignment of pieces', 'Force the king to move first'],
      category: 'Tactics',
      xpReward: 75,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 160,
      solveCount: 150,
    ),

    // Discovered attack
    PuzzleModel(
      id: 'puzzle_006',
      fen: '8/8/8/3q4/3P4/3R4/3K4/8 w - - 0 1',
      solution: ['d4d5'],
      theme: 'Discovered Attack',
      difficulty: 3,
      rating: 1200,
      description: 'Moving one piece reveals an attack from another behind it.',
      hints: ['Consider moving the pawn', 'What is revealed when it moves?'],
      category: 'Tactics',
      xpReward: 100,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 140,
      solveCount: 130,
    ),

    // Sacrifice puzzle
    PuzzleModel(
      id: 'puzzle_007',
      fen: 'rn1qkbnr/pp1ppppp/8/2p5/4P3/5Q2/PPPP1PPP/RNB1KBNR w KQkq c6 0 1',
      solution: ['f3c6'],
      theme: 'Sacrifice',
      difficulty: 3,
      rating: 1250,
      description: 'A queen sacrifice leads to a winning position.',
      hints: ['Consider sacrificing your queen', 'What tactical blow follows?'],
      category: 'Combinations',
      xpReward: 100,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 120,
      solveCount: 100,
    ),

    // Defensive tactic
    PuzzleModel(
      id: 'puzzle_008',
      fen: '3r3r/5pk1/8/8/8/5K2/5R2/8 b - - 0 1',
      solution: ['h8f8'],
      theme: 'Defensive Tactic',
      difficulty: 2,
      rating: 1100,
      description: 'Find the best defense to prevent a tactical blow.',
      hints: ['Block the threats', 'Centralize your pieces'],
      category: 'Defense',
      xpReward: 75,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 100,
      solveCount: 85,
    ),

    // Endgame tactic
    PuzzleModel(
      id: 'puzzle_009',
      fen: '8/1k6/1K6/8/8/8/8/8 w - - 0 1',
      solution: ['b6a6'],
      theme: 'Endgame Tactic',
      difficulty: 1,
      rating: 950,
      description: 'In endgames, king activity is crucial.',
      hints: ['Advance your king', 'Cut off the enemy king'],
      category: 'Endgame',
      xpReward: 60,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 90,
      solveCount: 80,
    ),

    // Checkmate in 2
    PuzzleModel(
      id: 'puzzle_010',
      fen: '6k1/5Q2/6K1/8/8/8/8/8 w - - 0 1',
      solution: ['f7f8', 'g8h7'],
      theme: 'Checkmate in 2',
      difficulty: 3,
      rating: 1300,
      description: 'Find the forced checkmate sequence.',
      hints: ['Start with a check', 'The second move must be unstoppable'],
      category: 'Checkmate',
      xpReward: 100,
      isDaily: false,
      createdAt: DateTime.now(),
      attempts: 150,
      solveCount: 130,
    ),
  ];

  /// Gets daily puzzle (rotates daily)
  static PuzzleModel getDailyPuzzle() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    final puzzleIndex = dayOfYear % _samplePuzzles.length;
    
    return _samplePuzzles[puzzleIndex].copyWith(isDaily: true);
  }

  /// Gets a random puzzle of specified difficulty
  static PuzzleModel getRandomPuzzle({int? difficulty}) {
    List<PuzzleModel> available = _samplePuzzles;

    if (difficulty != null) {
      available = available.where((p) => p.difficulty == difficulty).toList();
    }

    if (available.isEmpty) {
      return _samplePuzzles[0];
    }

    available.shuffle();
    return available[0];
  }

  /// Gets multiple puzzles for a session
  static List<PuzzleModel> getPuzzleSet({
    int count = 5,
    int? difficulty,
    String? category,
  }) {
    List<PuzzleModel> available = _samplePuzzles;

    if (difficulty != null) {
      available = available.where((p) => p.difficulty == difficulty).toList();
    }

    if (category != null) {
      available = available.where((p) => p.category == category).toList();
    }

    available.shuffle();
    return available.take(count).toList();
  }

  /// Gets puzzles by theme
  static List<PuzzleModel> getPuzzlesByTheme(String theme) {
    return _samplePuzzles.where((p) => p.theme == theme).toList();
  }

  /// Gets puzzles by category
  static List<PuzzleModel> getPuzzlesByCategory(String category) {
    return _samplePuzzles.where((p) => p.category == category).toList();
  }

  /// Gets all unique themes
  static List<String> getAllThemes() {
    final themes = <String>{};
    for (final puzzle in _samplePuzzles) {
      themes.add(puzzle.theme);
    }
    return themes.toList();
  }

  /// Gets all unique categories
  static List<String> getAllCategories() {
    final categories = <String>{};
    for (final puzzle in _samplePuzzles) {
      categories.add(puzzle.category);
    }
    return categories.toList();
  }

  /// Gets puzzles by difficulty level
  static List<PuzzleModel> getPuzzlesByDifficulty(int difficulty) {
    return _samplePuzzles.where((p) => p.difficulty == difficulty).toList();
  }

  /// Finds puzzle by ID
  static PuzzleModel? getPuzzleById(String id) {
    try {
      return _samplePuzzles.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets progressive puzzle set (starts easy, gets harder)
  static List<PuzzleModel> getProgressivePuzzleSet({int count = 10}) {
    final progressive = <PuzzleModel>[];

    for (int difficulty = 1; difficulty <= 5; difficulty++) {
      final puzzlesAtDifficulty = getPuzzlesByDifficulty(difficulty);
      final needed = (count / 5).ceil();
      puzzlesAtDifficulty.shuffle();
      progressive.addAll(puzzlesAtDifficulty.take(needed));
    }

    return progressive.take(count).toList();
  }
}
