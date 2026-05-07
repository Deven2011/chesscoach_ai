import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/puzzle_model.dart';
import 'package:en_passant/models/puzzle_attempt_model.dart';
import 'package:en_passant/models/puzzle_progress_model.dart';
import 'package:en_passant/widgets/puzzles/puzzle_result_overlay.dart';

/// Screen showing puzzle completion results and statistics
class PuzzleResultScreen extends StatefulWidget {
  final PuzzleModel puzzle;
  final PuzzleAttemptModel attempt;
  final PuzzleProgressModel progress;

  const PuzzleResultScreen({
    Key? key,
    required this.puzzle,
    required this.attempt,
    required this.progress,
  }) : super(key: key);

  @override
  State<PuzzleResultScreen> createState() => _PuzzleResultScreenState();
}

class _PuzzleResultScreenState extends State<PuzzleResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solveTime = widget.attempt.solvingTime;
    final accuracy =
        (widget.attempt.moveSequence.length / widget.puzzle.solution.length) *
            100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Result'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Result overlay
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1).animate(
                      CurvedAnimation(
                          parent: _scaleController, curve: Curves.elasticOut),
                    ),
                    child: PuzzleResultOverlay(
                      correct: widget.attempt.correct,
                      theme: widget.puzzle.theme,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats section
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                          parent: _slideController, curve: Curves.easeOut),
                    ),
                    child: Column(
                      children: [
                        // Time and accuracy
                        _buildStatRow(
                          'Solve Time',
                          _formatDuration(solveTime),
                          Icons.timer,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          'Accuracy',
                          '${accuracy.toStringAsFixed(0)}%',
                          Icons.precision_manufacturing,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          'Hints Used',
                          widget.attempt.hintsUsed.toString(),
                          Icons.lightbulb,
                        ),
                        const SizedBox(height: 24),

                        // XP earned
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'XP Earned',
                                style: AppTextStyles.textTheme()
                                    .labelMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '+${widget.attempt.xpEarned}',
                                    style: AppTextStyles.textTheme()
                                        .headlineSmall
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (widget.attempt.streakBonus > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '+${widget.attempt.streakBonus} 🔥',
                                        style: AppTextStyles.textTheme()
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.secondary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total XP: ${widget.progress.totalXpEarned}',
                                style: AppTextStyles.textTheme()
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Puzzle explanation
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tactical Explanation',
                                style: AppTextStyles.textTheme()
                                    .labelLarge
                                    ?.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.puzzle.description,
                                style: AppTextStyles.textTheme()
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurface,
                                      height: 1.6,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Streak info
                        if (widget.progress.currentStreak > 0)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '🔥 Streak Active! 🔥',
                                  style: AppTextStyles.textTheme()
                                      .labelLarge
                                      ?.copyWith(
                                        color: AppColors.secondary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.progress.currentStreak} day${widget.progress.currentStreak > 1 ? 's' : ''}',
                                  style: AppTextStyles.textTheme()
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColors.secondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),

                        // Action buttons
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                          ),
                          child: Text(
                            'Next Puzzle',
                            style:
                                AppTextStyles.textTheme().labelLarge?.copyWith(
                                      color: AppColors.onPrimary,
                                    ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Back to Menu',
                            style:
                                AppTextStyles.textTheme().labelLarge?.copyWith(
                                      color: AppColors.primary,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.textTheme().bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.textTheme().bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${(duration.inMinutes % 60)}m';
    }
  }
}
