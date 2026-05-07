import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

/// Widget showing progress through puzzle solution
class PuzzleProgressIndicator extends StatelessWidget {
  final int current;
  final int total;

  const PuzzleProgressIndicator({
    Key? key,
    required this.current,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (current / total) : 0.0;
    final isComplete = current >= total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Puzzle Progress',
                style: AppTextStyles.textTheme().labelLarge?.copyWith(
                      color: AppColors.onSurface,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$current/$total',
                  style: AppTextStyles.textTheme().labelSmall?.copyWith(
                        color: isComplete ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: AppColors.border.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(0)}% Complete',
                style: AppTextStyles.textTheme().labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              if (isComplete)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '✨ Perfect!',
                    style: AppTextStyles.textTheme().labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
