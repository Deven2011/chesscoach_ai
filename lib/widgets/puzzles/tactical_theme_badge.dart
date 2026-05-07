import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

/// Widget displaying tactical theme badge with statistics
class TacticalThemeBadge extends StatelessWidget {
  final String theme;
  final int count;
  final double percentage;

  const TacticalThemeBadge({
    Key? key,
    required this.theme,
    required this.count,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getThemeColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getThemeIcon(),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            theme,
                            style: AppTextStyles.textTheme().bodyLarge?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count puzzle${count != 1 ? 's' : ''} solved',
                      style: AppTextStyles.textTheme().labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.textTheme().labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: AppColors.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getThemeColor() {
    final themeColors = {
      'Checkmate in 1': AppColors.primary,
      'Checkmate in 2': AppColors.primaryLight,
      'Fork': AppColors.secondary,
      'Pin': AppColors.accent,
      'Skewer': AppColors.accentLight,
      'Discovered Attack': AppColors.primaryLight,
      'Sacrifice': AppColors.secondary,
      'Defensive Tactic': AppColors.primary,
      'Endgame Tactic': AppColors.accent,
    };

    return themeColors[theme] ?? AppColors.primary;
  }

  String _getThemeIcon() {
    final themeIcons = {
      'Checkmate in 1': '♛',
      'Checkmate in 2': '♚',
      'Fork': '🍴',
      'Pin': '📌',
      'Skewer': '⚔️',
      'Discovered Attack': '💥',
      'Sacrifice': '💎',
      'Defensive Tactic': '🛡️',
      'Endgame Tactic': '🏁',
    };

    return themeIcons[theme] ?? '♞';
  }
}
