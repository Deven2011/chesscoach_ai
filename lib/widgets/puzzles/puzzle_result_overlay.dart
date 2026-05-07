import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

/// Overlay widget showing puzzle completion result
class PuzzleResultOverlay extends StatelessWidget {
  final bool correct;
  final String theme;

  const PuzzleResultOverlay({
    Key? key,
    required this.correct,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (correct ? AppColors.success : AppColors.error)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (correct ? AppColors.success : AppColors.error)
              .withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Result icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (correct ? AppColors.success : AppColors.error)
                  .withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              correct ? Icons.check_circle : Icons.cancel,
              color: correct ? AppColors.success : AppColors.error,
              size: 64,
            ),
          ),
          const SizedBox(height: 16),

          // Result text
          Text(
            correct ? 'Puzzle Solved!' : 'Try Again',
            style: AppTextStyles.textTheme().headlineSmall?.copyWith(
                  color: correct ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Theme text
          Text(
            theme,
            style: AppTextStyles.textTheme().bodyMedium?.copyWith(
                  color: correct
                      ? AppColors.success.withOpacity(0.8)
                      : AppColors.error.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }
}
