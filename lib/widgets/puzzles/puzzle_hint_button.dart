import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

/// Widget for displaying hint button with usage count
class PuzzleHintButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int hintsUsed;
  final int maxHints;

  const PuzzleHintButton({
    Key? key,
    required this.onPressed,
    required this.hintsUsed,
    this.maxHints = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hintsRemaining = maxHints - hintsUsed;
    final canUseHint = hintsRemaining > 0;

    return Container(
      decoration: BoxDecoration(
        color: canUseHint
            ? AppColors.secondary.withOpacity(0.1)
            : AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canUseHint
              ? AppColors.secondary.withOpacity(0.5)
              : AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canUseHint ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb,
                  color: canUseHint
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get a Hint',
                      style: AppTextStyles.textTheme().labelMedium?.copyWith(
                            color: canUseHint
                                ? AppColors.secondary
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$hintsRemaining hint${hintsRemaining != 1 ? 's' : ''} remaining',
                      style: AppTextStyles.textTheme().labelSmall?.copyWith(
                            color: canUseHint
                                ? AppColors.secondary.withOpacity(0.7)
                                : AppColors.onSurfaceVariant.withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
