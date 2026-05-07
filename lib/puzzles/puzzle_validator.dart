import 'package:en_passant/models/puzzle_model.dart';

/// Validates puzzle moves against the actual chess engine
class PuzzleValidator {
  /// Validates if a move is legal in chess
  static bool isLegalChessMove(String moveUci) {
    // moveUci format: e2e4 (from square to square)
    // Additional format: e2e4q (promotion with piece)

    if (moveUci.length < 4 || moveUci.length > 5) {
      return false;
    }

    final fromSquare = moveUci.substring(0, 2);
    final toSquare = moveUci.substring(2, 4);

    // Validate square notation (a1-h8)
    return _isValidSquare(fromSquare) && _isValidSquare(toSquare);
  }

  /// Checks if square notation is valid
  static bool _isValidSquare(String square) {
    if (square.length != 2) return false;

    final file = square.codeUnitAt(0);
    final rank = square.codeUnitAt(1);

    // a-h (97-104) and 1-8 (49-56)
    return (file >= 97 && file <= 104) && (rank >= 49 && rank <= 56);
  }

  /// Validates move sequence for puzzle completion
  static bool validateMoveSequence(List<String> moves, List<String> solution) {
    if (moves.length > solution.length) {
      return false;
    }

    for (int i = 0; i < moves.length; i++) {
      final normalizedInput = moves[i].toLowerCase().trim();
      final normalizedExpected = solution[i].toLowerCase().trim();

      if (normalizedInput != normalizedExpected) {
        return false;
      }
    }

    return true;
  }

  /// Checks if puzzle is correctly solved
  static bool isPuzzleSolved(List<String> moves, List<String> solution) {
    if (moves.length != solution.length) {
      return false;
    }

    return validateMoveSequence(moves, solution);
  }

  /// Gets the next expected move
  static String? getNextMove(List<String> moves, List<String> solution) {
    if (moves.length < solution.length) {
      return solution[moves.length];
    }
    return null;
  }

  /// Validates puzzle structure
  static List<String> validatePuzzleStructure(PuzzleModel puzzle) {
    final errors = <String>[];

    // Check FEN validity
    if (puzzle.fen.isEmpty) {
      errors.add('FEN position is empty');
    }

    // Check solution exists and is not empty
    if (puzzle.solution.isEmpty) {
      errors.add('Solution is empty');
    }

    // Check all moves in solution are valid
    for (final move in puzzle.solution) {
      if (!isLegalChessMove(move)) {
        errors.add('Invalid move in solution: $move');
      }
    }

    // Check metadata
    if (puzzle.theme.isEmpty) {
      errors.add('Theme is not specified');
    }

    if (puzzle.difficulty < 1 || puzzle.difficulty > 5) {
      errors.add('Difficulty must be between 1 and 5');
    }

    if (puzzle.xpReward <= 0) {
      errors.add('XP reward must be positive');
    }

    return errors;
  }

  /// Estimates puzzle difficulty based on solution length and theme
  static int estimateDifficulty(List<String> solution, String theme) {
    int difficulty = 1;

    // Increase difficulty based on solution length
    if (solution.length >= 3) difficulty = 2;
    if (solution.length >= 5) difficulty = 3;
    if (solution.length >= 7) difficulty = 4;

    // Adjust based on theme complexity
    final complexThemes = [
      'Checkmate in 2',
      'Discovered Attack',
      'Sacrifice',
      'Combination',
    ];

    if (complexThemes.contains(theme) && difficulty < 3) {
      difficulty = 3;
    }

    // Cap at 5
    if (difficulty > 5) difficulty = 5;

    return difficulty;
  }

  /// Calculates XP reward based on puzzle properties
  static int calculateXpReward({
    required int difficulty,
    required int solvingTimeSeconds,
    required bool usedHints,
  }) {
    // Base XP for difficulty
    int xp = difficulty * 25;

    // Bonus for solving quickly (under 1 minute)
    if (solvingTimeSeconds < 60) {
      xp += 25;
    }

    // Penalty for using hints
    if (usedHints) {
      xp = (xp * 0.75).toInt();
    }

    return xp.clamp(50, 300).toInt();
  }

  /// Validates hint relevance
  static bool isValidHint(String hint) {
    return hint.isNotEmpty && hint.length < 200;
  }

  /// Checks if position is valid for a puzzle (not checkmate/stalemate position)
  static bool isValidPuzzlePosition(String fen) {
    // Basic FEN validation
    final parts = fen.split(' ');
    return parts.length == 6; // Full FEN with move counters
  }

  /// Calculates move accuracy percentage
  static double calculateAccuracy(
    List<String> playerMoves,
    List<String> solutionMoves,
  ) {
    if (solutionMoves.isEmpty) return 100;

    int correctMoves = 0;
    for (int i = 0; i < playerMoves.length && i < solutionMoves.length; i++) {
      if (playerMoves[i].toLowerCase().trim() ==
          solutionMoves[i].toLowerCase().trim()) {
        correctMoves++;
      }
    }

    return (correctMoves / solutionMoves.length) * 100;
  }

  /// Validates attempt data before saving
  static List<String> validateAttemptData({
    required String puzzleId,
    required List<String> moves,
    required int hintsUsed,
    required int solvingTime,
  }) {
    final errors = <String>[];

    if (puzzleId.isEmpty) errors.add('Puzzle ID is required');
    if (moves.isEmpty) errors.add('No moves were made');
    if (hintsUsed < 0) errors.add('Hints used cannot be negative');
    if (solvingTime < 0) errors.add('Solving time cannot be negative');

    // Check for reasonable solving time (not more than 1 hour)
    if (solvingTime > 3600) {
      errors.add('Solving time is unreasonably long');
    }

    return errors;
  }
}
