import 'package:en_passant/models/puzzle_model.dart';
import 'package:en_passant/models/puzzle_attempt_model.dart';

/// Core puzzle engine for validating moves and managing puzzle gameplay
class PuzzleEngine {
  late PuzzleModel currentPuzzle;
  late List<String> playerMoves;
  late bool isCompleted;
  late bool isSolved;
  late DateTime startTime;

  void initializePuzzle(PuzzleModel puzzle) {
    currentPuzzle = puzzle;
    playerMoves = [];
    isCompleted = false;
    isSolved = false;
    startTime = DateTime.now();
  }

  /// Validates if a move is valid in the puzzle solution path
  bool validateMove(String moveUci) {
    if (isCompleted || isSolved) return false;

    // Check if the move is the next expected move in the solution
    if (playerMoves.length < currentPuzzle.solution.length) {
      final expectedMove = currentPuzzle.solution[playerMoves.length];
      
      // Normalize moves for comparison (handle various UCI formats)
      final normalizedInput = moveUci.toLowerCase().trim();
      final normalizedExpected = expectedMove.toLowerCase().trim();

      if (normalizedInput == normalizedExpected) {
        playerMoves.add(moveUci);
        
        // Check if puzzle is solved
        if (playerMoves.length == currentPuzzle.solution.length) {
          isCompleted = true;
          isSolved = true;
        }
        return true;
      }
    }

    return false;
  }

  /// Checks if the puzzle is solved
  bool checkPuzzleSolved() {
    if (playerMoves.length == currentPuzzle.solution.length) {
      isSolved = true;
      isCompleted = true;
      return true;
    }
    return false;
  }

  /// Gets the next expected move in the solution
  String? getNextExpectedMove() {
    if (playerMoves.length < currentPuzzle.solution.length) {
      return currentPuzzle.solution[playerMoves.length];
    }
    return null;
  }

  /// Gets progress through the puzzle (percentage)
  double getProgressPercentage() {
    if (currentPuzzle.solution.isEmpty) return 100;
    return (playerMoves.length / currentPuzzle.solution.length) * 100;
  }

  /// Gets the current move count
  int getCurrentMoveCount() {
    return playerMoves.length;
  }

  /// Gets the total number of moves needed to solve
  int getTotalMovesNeeded() {
    return currentPuzzle.solution.length;
  }

  /// Resets the puzzle to initial state
  void resetPuzzle() {
    playerMoves = [];
    isCompleted = false;
    isSolved = false;
    startTime = DateTime.now();
  }

  /// Gets the solving time
  Duration getSolvingTime() {
    return DateTime.now().difference(startTime);
  }

  /// Validates the complete solution at once
  bool validateCompleteSolution(List<String> moves) {
    if (moves.length != currentPuzzle.solution.length) {
      return false;
    }

    for (int i = 0; i < moves.length; i++) {
      final normalizedInput = moves[i].toLowerCase().trim();
      final normalizedExpected = currentPuzzle.solution[i].toLowerCase().trim();
      
      if (normalizedInput != normalizedExpected) {
        return false;
      }
    }

    return true;
  }

  /// Gets hint suggestions
  List<String> getHintSuggestions({int hintCount = 1}) {
    final hints = <String>[];
    
    if (currentPuzzle.hints.isEmpty) {
      // If no custom hints, suggest next moves from solution
      for (int i = playerMoves.length; i < playerMoves.length + hintCount && i < currentPuzzle.solution.length; i++) {
        hints.add('Next move: ${currentPuzzle.solution[i]}');
      }
    } else {
      // Return custom hints
      hints.addAll(currentPuzzle.hints.take(hintCount));
    }

    return hints;
  }

  /// Creates a puzzle attempt record
  PuzzleAttemptModel createAttempt({
    required String userId,
    required int hintsUsed,
    required int xpEarned,
    required int streakBonus,
    String? feedback,
  }) {
    final solvingTime = getSolvingTime();

    return PuzzleAttemptModel(
      id: '', // Will be set by Firestore
      userId: userId,
      puzzleId: currentPuzzle.id,
      attemptedAt: DateTime.now(),
      completed: isCompleted,
      correct: isSolved,
      solvingTime: solvingTime,
      moveSequence: playerMoves,
      hintsUsed: hintsUsed,
      xpEarned: xpEarned,
      streakBonus: streakBonus,
      feedback: feedback,
    );
  }

  /// Gets tactical explanation of the puzzle
  String getTacticalExplanation() {
    return currentPuzzle.description;
  }

  /// Gets category badge
  String getCategory() {
    return currentPuzzle.category;
  }

  /// Gets theme/tactic type
  String getTheme() {
    return currentPuzzle.theme;
  }

  /// Gets difficulty level
  int getDifficulty() {
    return currentPuzzle.difficulty;
  }

  /// Gets rating (estimated skill level)
  int getRating() {
    return currentPuzzle.rating;
  }
}
