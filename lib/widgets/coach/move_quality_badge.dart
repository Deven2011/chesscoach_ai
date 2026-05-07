import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/move_review_model.dart';

class MoveQualityBadge extends StatelessWidget {
  final MoveQuality quality;
  final bool compact;

  const MoveQualityBadge({
    super.key,
    required this.quality,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = _label(quality);
    final color = _color(quality);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 11,
          vertical: compact ? 5 : 7,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(quality), size: compact ? 13 : 15, color: color),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _label(MoveQuality quality) {
    return quality.name[0].toUpperCase() + quality.name.substring(1);
  }

  Color _color(MoveQuality quality) {
    switch (quality) {
      case MoveQuality.brilliant:
        return const Color(0xFF00D1FF);
      case MoveQuality.great:
      case MoveQuality.best:
        return AppColors.secondary;
      case MoveQuality.excellent:
      case MoveQuality.good:
        return AppColors.primary;
      case MoveQuality.inaccuracy:
      case MoveQuality.miss:
        return AppColors.accent;
      case MoveQuality.mistake:
      case MoveQuality.blunder:
        return AppColors.error;
    }
  }

  IconData _icon(MoveQuality quality) {
    switch (quality) {
      case MoveQuality.brilliant:
        return Icons.diamond_rounded;
      case MoveQuality.great:
        return Icons.auto_awesome_rounded;
      case MoveQuality.best:
        return Icons.verified_rounded;
      case MoveQuality.excellent:
        return Icons.trending_up_rounded;
      case MoveQuality.good:
        return Icons.check_circle_rounded;
      case MoveQuality.inaccuracy:
        return Icons.warning_amber_rounded;
      case MoveQuality.miss:
        return Icons.search_off_rounded;
      case MoveQuality.mistake:
        return Icons.error_outline_rounded;
      case MoveQuality.blunder:
        return Icons.dangerous_rounded;
    }
  }
}
