import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/providers/puzzle_provider.dart';
import 'package:en_passant/providers/auth_provider.dart';
import 'package:en_passant/widgets/puzzles/puzzle_card.dart';
import 'package:en_passant/widgets/puzzles/puzzle_hint_button.dart';
import 'package:en_passant/widgets/puzzles/puzzle_progress_indicator.dart';
import 'package:en_passant/widgets/puzzles/puzzle_streak_card.dart';
import 'puzzle_result_screen.dart';

/// Main screen for solving daily chess puzzles
class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({Key? key}) : super(key: key);

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  late TextEditingController _moveController;
  bool _canSubmit = false;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _moveController = TextEditingController();
    _moveController.addListener(() {
      setState(() => _canSubmit = _moveController.text.isNotEmpty);
    });

    // Load daily puzzle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PuzzleProvider>().loadDailyPuzzle();
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PuzzleProvider>(
      builder: (context, puzzleProvider, _) {
        if (puzzleProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Daily Puzzle')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading puzzle...',
                    style: AppTextStyles.textTheme().bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        if (puzzleProvider.currentPuzzle == null &&
            puzzleProvider.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Daily Puzzle')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${puzzleProvider.errorMessage}',
                    style: AppTextStyles.textTheme().bodyLarge?.copyWith(
                          color: AppColors.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => puzzleProvider.loadDailyPuzzle(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (puzzleProvider.currentPuzzle == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Daily Puzzle')),
            body: const Center(
              child: Text('No puzzle available'),
            ),
          );
        }

        final puzzle = puzzleProvider.currentPuzzle!;
        final alreadyCompleted = puzzleProvider.hasCompletedDailyToday();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily Puzzle'),
            elevation: 0,
            backgroundColor: AppColors.surface,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Streak card
                  if (puzzleProvider.userProgress != null)
                    PuzzleStreakCard(
                      progress: puzzleProvider.userProgress!,
                      completed: alreadyCompleted,
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 16),

                  // Puzzle card with board
                  PuzzleCard(
                    puzzle: puzzle,
                    playedMoves: puzzleProvider.playerMoves,
                    interactive: !alreadyCompleted,
                    onMoveSelected: alreadyCompleted
                        ? null
                        : (move) => _submitMove(puzzleProvider, move: move),
                  ),
                  const SizedBox(height: 24),

                  // Puzzle info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Theme: ${puzzle.theme}',
                              style: AppTextStyles.textTheme()
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Level ${puzzle.difficulty}',
                                style: AppTextStyles.textTheme()
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          puzzle.description,
                          style: AppTextStyles.textTheme().bodySmall?.copyWith(
                                color: AppColors.onSurface,
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress indicator
                  PuzzleProgressIndicator(
                    current: puzzleProvider.playerMoves.length,
                    total: puzzle.solution.length,
                  ),
                  const SizedBox(height: 24),

                  // Move input
                  if (!alreadyCompleted)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _moveController,
                          decoration: InputDecoration(
                            hintText: 'Enter move (e.g., e2e4)',
                            hintStyle: TextStyle(
                              color:
                                  AppColors.onSurfaceVariant.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.edit,
                              color: AppColors.primary,
                            ),
                            suffixIcon: _moveController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: _moveController.clear,
                                  )
                                : null,
                          ),
                          style: AppTextStyles.textTheme().bodyMedium,
                          onSubmitted: (value) {
                            if (_canSubmit) {
                              _submitMove(puzzleProvider);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _canSubmit
                              ? () => _submitMove(puzzleProvider)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _canSubmit
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.5),
                          ),
                          child: Text(
                            'Submit Move',
                            style:
                                AppTextStyles.textTheme().labelLarge?.copyWith(
                                      color: AppColors.onPrimary,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Hint button
                  if (!alreadyCompleted)
                    PuzzleHintButton(
                      onPressed: () => _getHint(puzzleProvider),
                      hintsUsed: puzzleProvider.hintsUsed,
                    ),
                  const SizedBox(height: 16),

                  // Error message
                  if (puzzleProvider.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        puzzleProvider.errorMessage!,
                        style: AppTextStyles.textTheme().bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Reset button
                  if (!alreadyCompleted)
                    TextButton.icon(
                      onPressed: () {
                        _resultShown = false;
                        puzzleProvider.resetPuzzle();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Puzzle'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitMove(PuzzleProvider provider, {String? move}) {
    final submittedMove = move ?? _moveController.text.trim();
    if (submittedMove.isEmpty) return;

    final success = provider.submitMove(submittedMove);

    if (success) {
      _moveController.clear();
      setState(() => _canSubmit = false);

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.playerMoves.length ==
                    provider.currentPuzzle?.solution.length
                ? '✨ Puzzle solved!'
                : '✓ Correct move! ${provider.currentPuzzle!.solution.length - provider.playerMoves.length} moves remaining',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      if (provider.puzzleCompleted && !_resultShown) {
        _resultShown = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showResultScreen(context, provider);
          }
        });
      }
    }
  }

  void _getHint(PuzzleProvider provider) {
    final hints = provider.getHints();
    if (hints.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Hint'),
          content: Text(hints.first),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    }
  }

  void _showResultScreen(BuildContext context, PuzzleProvider provider) {
    final auth = context.read<AuthProvider>();
    final attempt = provider.createAttemptRecord(auth.user?.uid ?? '');

    provider.updateProgressWithAttempt(attempt);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PuzzleResultScreen(
          puzzle: provider.currentPuzzle!,
          attempt: attempt,
          progress: provider.userProgress!,
        ),
      ),
    );
  }
}
