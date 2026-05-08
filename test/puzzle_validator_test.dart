import 'package:en_passant/models/puzzle_model.dart';
import 'package:en_passant/puzzles/puzzle_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PuzzleValidator', () {
    testWidgets('accepts valid UCI moves and rejects invalid squares',
        (tester) async {
      expect(PuzzleValidator.isLegalChessMove('e2e4'), isTrue);
      expect(PuzzleValidator.isLegalChessMove('a7a8q'), isTrue);
      expect(PuzzleValidator.isLegalChessMove('i2e4'), isFalse);
      expect(PuzzleValidator.isLegalChessMove('e9e4'), isFalse);
      expect(PuzzleValidator.isLegalChessMove('e2'), isFalse);
    });

    testWidgets('validates partial and complete solution sequences',
        (tester) async {
      const solution = ['e2e4', 'e7e5', 'g1f3'];

      expect(
        PuzzleValidator.validateMoveSequence(['E2E4 ', 'e7e5'], solution),
        isTrue,
      );
      expect(
        PuzzleValidator.validateMoveSequence(['e2e4', 'd7d5'], solution),
        isFalse,
      );
      expect(PuzzleValidator.isPuzzleSolved(solution, solution), isTrue);
      expect(PuzzleValidator.getNextMove(['e2e4'], solution), 'e7e5');
    });

    testWidgets('reports puzzle structure errors and calculates XP',
        (tester) async {
      final validPuzzle = PuzzleModel(
        id: 'daily-001',
        fen: '8/8/8/8/8/8/4K3/4k3 w - - 0 1',
        solution: const ['e2e3'],
        theme: 'Defense',
        difficulty: 2,
        rating: 1100,
        description: 'Find the best defensive move.',
        hints: const ['Move the king.'],
        createdAt: DateTime(2026),
        attempts: 0,
        solveCount: 0,
        category: 'Defense',
        xpReward: 75,
        isDaily: true,
      );

      expect(PuzzleValidator.validatePuzzleStructure(validPuzzle), isEmpty);
      expect(
        PuzzleValidator.calculateXpReward(
          difficulty: 2,
          solvingTimeSeconds: 45,
          usedHints: false,
        ),
        75,
      );
      expect(
        PuzzleValidator.validateAttemptData(
          puzzleId: '',
          moves: const [],
          hintsUsed: -1,
          solvingTime: 3601,
        ),
        containsAll(<String>[
          'Puzzle ID is required',
          'No moves were made',
          'Hints used cannot be negative',
          'Solving time is unreasonably long',
        ]),
      );
    });
  });
}
