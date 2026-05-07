import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/puzzle_progress_model.dart';

/// Widget displaying user's puzzle streak status
class PuzzleStreakCard extends StatelessWidget {
  final PuzzleProgressModel progress;
  final bool completed;

  const PuzzleStreakCard({
    Key? key,
    required this.progress,
    required this.completed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.2),
            AppColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '🔥',
                        style: AppTextStyles.textTheme().headlineSmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Streak',
                        style: AppTextStyles.textTheme().labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.currentStreak} day${progress.currentStreak != 1 ? 's' : ''}',
                    style: AppTextStyles.textTheme().headlineSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Best',
                    style: AppTextStyles.textTheme().labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '👑 ${progress.longestStreak}',
                    style: AppTextStyles.textTheme().bodyLarge?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color:
                      completed ? AppColors.success : AppColors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  completed
                      ? 'Daily puzzle completed! ✨'
                      : 'Solve today\'s puzzle to keep your streak',
                  style: AppTextStyles.textTheme().bodySmall?.copyWith(
                        color: completed
                            ? AppColors.success
                            : AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
