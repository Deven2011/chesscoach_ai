import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:en_passant/firebase/firestore_service.dart';
import 'package:en_passant/models/puzzle_model.dart';
import 'package:en_passant/models/puzzle_attempt_model.dart';
import 'package:en_passant/models/puzzle_progress_model.dart';
import 'package:en_passant/puzzles/puzzle_engine.dart';
import 'package:en_passant/puzzles/puzzle_generator.dart';
import 'package:en_passant/puzzles/puzzle_validator.dart';
import 'package:en_passant/puzzles/puzzle_progress_tracker.dart';

/// Provider for managing puzzle state and interactions
class PuzzleProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final PuzzleEngine _engine = PuzzleEngine();
  StreamSubscription<PuzzleProgressModel?>? _progressSubscription;

  // State
  PuzzleModel? _currentPuzzle;
  PuzzleProgressModel? _userProgress;
  List<PuzzleAttemptModel> _attemptHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _hintsUsed = 0;
  int _movesAttempted = 0;
  List<String> _playerMoves = [];
  bool _puzzleCompleted = false;
  DateTime? _puzzleStartTime;
  String? _activeUserId;
  final Set<String> _savedAttemptKeys = {};

  PuzzleProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Getters
  PuzzleModel? get currentPuzzle => _currentPuzzle;
  PuzzleProgressModel? get userProgress => _userProgress;
  List<PuzzleAttemptModel> get attemptHistory => _attemptHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get hintsUsed => _hintsUsed;
  int get movesAttempted => _movesAttempted;
  List<String> get playerMoves => _playerMoves;
  bool get puzzleCompleted => _puzzleCompleted;
  double get solveAccuracy {
    if (_playerMoves.isEmpty || (_currentPuzzle?.solution.isEmpty ?? true)) {
      return 0;
    }
    return PuzzleValidator.calculateAccuracy(
      _playerMoves,
      _currentPuzzle!.solution,
    );
  }

  /// Binds puzzle progress to the signed-in user.
  void bindUser(String? userId) {
    if (_activeUserId == userId) return;
    _activeUserId = userId;
    _progressSubscription?.cancel();
    _attemptHistory = [];
    _errorMessage = null;

    if (userId == null) {
      _userProgress = PuzzleProgressModel.empty('guest');
      _isLoading = false;
      scheduleMicrotask(notifyListeners);
      return;
    }

    _isLoading = true;
    scheduleMicrotask(notifyListeners);
    _progressSubscription =
        _firestoreService.watchPuzzleProgress(userId).listen(
      (progress) {
        _userProgress = progress ?? PuzzleProgressModel.empty(userId);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _userProgress ??= PuzzleProgressModel.empty(userId);
        _isLoading = false;
        _errorMessage = 'Could not load puzzle progress.';
        notifyListeners();
      },
    );

    unawaited(_loadAttemptHistory(userId));
  }

  /// Initializes user progress
  void initializeProgress(String userId) {
    _userProgress = PuzzleProgressModel.empty(userId);
    _playerMoves = [];
    _hintsUsed = 0;
    _movesAttempted = 0;
    _puzzleCompleted = false;
    notifyListeners();
  }

  /// Loads user progress from data
  void loadProgress(PuzzleProgressModel progress) {
    _userProgress = progress;
    notifyListeners();
  }

  /// Loads daily puzzle
  Future<void> loadDailyPuzzle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final puzzle = PuzzleGenerator.getDailyPuzzle();
      await loadPuzzle(puzzle);
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to load daily puzzle: $e';
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Loads a specific puzzle
  Future<void> loadPuzzle(PuzzleModel puzzle) async {
    try {
      _currentPuzzle = puzzle;
      _engine.initializePuzzle(puzzle);
      _playerMoves = [];
      _hintsUsed = 0;
      _movesAttempted = 0;
      _puzzleCompleted = false;
      _puzzleStartTime = DateTime.now();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load puzzle: $e';
      notifyListeners();
    }
  }

  /// Loads a random puzzle of specified difficulty
  Future<void> loadRandomPuzzle({int? difficulty}) async {
    _setLoading(true);
    try {
      final puzzle = PuzzleGenerator.getRandomPuzzle(difficulty: difficulty);
      await loadPuzzle(puzzle);
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to load puzzle: $e';
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Loads a progressive puzzle set
  Future<List<PuzzleModel>> loadProgressivePuzzleSet({int count = 10}) async {
    _setLoading(true);
    try {
      final puzzles = PuzzleGenerator.getProgressivePuzzleSet(count: count);
      _setLoading(false);
      return puzzles;
    } catch (e) {
      _errorMessage = 'Failed to load puzzles: $e';
      _setLoading(false);
      notifyListeners();
      return [];
    }
  }

  /// Loads puzzles by theme
  Future<List<PuzzleModel>> loadPuzzlesByTheme(String theme) async {
    _setLoading(true);
    try {
      final puzzles = PuzzleGenerator.getPuzzlesByTheme(theme);
      _setLoading(false);
      return puzzles;
    } catch (e) {
      _errorMessage = 'Failed to load puzzles: $e';
      _setLoading(false);
      notifyListeners();
      return [];
    }
  }

  /// Submits a move in the puzzle
  bool submitMove(String moveUci) {
    if (_currentPuzzle == null) {
      _errorMessage = 'No puzzle loaded';
      notifyListeners();
      return false;
    }

    _movesAttempted++;

    // Validate move
    if (!PuzzleValidator.isLegalChessMove(moveUci)) {
      _errorMessage = 'Invalid chess move notation';
      notifyListeners();
      return false;
    }

    // Try to validate against puzzle solution
    if (_engine.validateMove(moveUci)) {
      _playerMoves = _engine.playerMoves;
      _errorMessage = null;

      // Check if puzzle is solved
      if (_engine.isSolved) {
        _completePuzzle();
      }

      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Incorrect move. Try again or use a hint.';
      notifyListeners();
      return false;
    }
  }

  /// Gets the next move hint
  List<String> getHints({int count = 1}) {
    if (_currentPuzzle == null) return [];

    _hintsUsed += count;
    final hints = _engine.getHintSuggestions(hintCount: count);
    notifyListeners();
    return hints;
  }

  /// Gets next expected move
  String? getNextMove() {
    return _engine.getNextExpectedMove();
  }

  /// Gets progress percentage
  double getProgressPercentage() {
    return _engine.getProgressPercentage();
  }

  /// Resets current puzzle
  void resetPuzzle() {
    if (_currentPuzzle != null) {
      _engine.resetPuzzle();
      _playerMoves = [];
      _hintsUsed = 0;
      _movesAttempted = 0;
      _puzzleCompleted = false;
      _puzzleStartTime = DateTime.now();
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Gets solving time
  Duration getSolvingTime() {
    if (_puzzleStartTime == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(_puzzleStartTime!);
  }

  /// Calculates XP earned
  int calculateXpEarned() {
    if (_currentPuzzle == null) return 0;

    final solvingTime = getSolvingTime().inSeconds;
    return PuzzleValidator.calculateXpReward(
      difficulty: _currentPuzzle!.difficulty,
      solvingTimeSeconds: solvingTime,
      usedHints: _hintsUsed > 0,
    );
  }

  /// Gets streak bonus
  int getStreakBonus() {
    if (_userProgress == null) return 0;
    return PuzzleProgressTracker.getStreakBonus(_userProgress!.currentStreak);
  }

  /// Creates attempt record
  PuzzleAttemptModel createAttemptRecord(String userId) {
    final xpEarned = calculateXpEarned();
    final streakBonus = _engine.isSolved ? getStreakBonus() : 0;

    return _engine.createAttempt(
      userId: userId,
      hintsUsed: _hintsUsed,
      xpEarned: xpEarned,
      streakBonus: streakBonus,
      feedback: _getCurrentFeedback(),
    );
  }

  /// Updates user progress with attempt
  void updateProgressWithAttempt(PuzzleAttemptModel attempt) {
    if (_userProgress == null || _currentPuzzle == null) return;

    _userProgress = PuzzleProgressTracker.updateProgress(
      currentProgress: _userProgress!,
      attempt: attempt,
      puzzle: _currentPuzzle!,
    );

    _attemptHistory.insert(0, attempt);
    unawaited(_persistAttemptAndProgress(attempt));
    notifyListeners();
  }

  /// Gets all themes
  List<String> getAvailableThemes() {
    return PuzzleGenerator.getAllThemes();
  }

  /// Gets all categories
  List<String> getAvailableCategories() {
    return PuzzleGenerator.getAllCategories();
  }

  /// Gets performance summary
  Map<String, dynamic> getPerformanceSummary() {
    if (_userProgress == null) return {};
    return PuzzleProgressTracker.getPerformanceSummary(_userProgress!);
  }

  /// Gets user tier
  String getUserTier() {
    if (_userProgress == null) return 'Novice';
    return PuzzleProgressTracker.getTierByXp(_userProgress!.totalXpEarned);
  }

  /// Gets next milestone
  Map<String, dynamic> getNextMilestone() {
    if (_userProgress == null) {
      return {
        'milestone': 'First Puzzle',
        'target': 1,
        'current': 0,
        'remaining': 1,
      };
    }
    return PuzzleProgressTracker.getNextMilestone(_userProgress!);
  }

  /// Gets motivation message
  String getMotivationMessage() {
    if (_userProgress == null) return 'Let\'s solve some puzzles!';
    return PuzzleProgressTracker.getMotivationMessage(_userProgress!);
  }

  /// Checks if daily puzzle is already completed
  bool hasCompletedDailyToday() {
    if (_userProgress == null) return false;
    return PuzzleProgressTracker.hasCompletedDailyToday(_userProgress!);
  }

  // Private methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _completePuzzle() {
    _puzzleCompleted = true;
  }

  Future<void> _loadAttemptHistory(String userId) async {
    try {
      _attemptHistory = await _firestoreService.getPuzzleAttempts(userId);
      notifyListeners();
    } on Object {
      // Progress is enough for the daily puzzle screen; history can recover later.
    }
  }

  Future<void> _persistAttemptAndProgress(PuzzleAttemptModel attempt) async {
    final userId = _activeUserId;
    final progress = _userProgress;
    if (userId == null || progress == null) return;

    final attemptKey = [
      userId,
      attempt.puzzleId,
      attempt.attemptedAt.millisecondsSinceEpoch,
      attempt.moveSequence.join(','),
    ].join(':');
    if (!_savedAttemptKeys.add(attemptKey)) return;

    try {
      await _firestoreService.savePuzzleAttempt(userId, attempt);
      await _firestoreService.savePuzzleProgress(
        userId: userId,
        progress: progress,
      );
    } on Object {
      _savedAttemptKeys.remove(attemptKey);
      _errorMessage = 'Puzzle solved, but progress could not be saved.';
      notifyListeners();
    }
  }

  String? _getCurrentFeedback() {
    if (_engine.isSolved) {
      return '✨ Perfect! Puzzle solved correctly!';
    }
    return 'Try again. Review the position and find the right moves.';
  }

  /// Gets strength areas
  List<String> getStrengths() {
    if (_userProgress == null) return [];
    return PuzzleProgressTracker.getStrengths(_userProgress!);
  }

  /// Gets areas for improvement
  List<String> getAreasForImprovement() {
    if (_userProgress == null) return [];
    return PuzzleProgressTracker.getAreasForImprovement(_userProgress!);
  }

  /// Gets recommended difficulty
  int getRecommendedDifficulty() {
    if (_userProgress == null) return 1;
    return PuzzleProgressTracker.getRecommendedDifficulty(_userProgress!);
  }

  /// Gets all available themes with puzzle counts
  Map<String, int> getThemesWithCounts() {
    final themes = <String, int>{};
    for (final theme in getAvailableThemes()) {
      themes[theme] = PuzzleGenerator.getPuzzlesByTheme(theme).length;
    }
    return themes;
  }

  /// Gets all available categories with puzzle counts
  Map<String, int> getCategoriesWithCounts() {
    final categories = <String, int>{};
    for (final category in getAvailableCategories()) {
      categories[category] =
          PuzzleGenerator.getPuzzlesByCategory(category).length;
    }
    return categories;
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}
