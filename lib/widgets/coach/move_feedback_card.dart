import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/move_review_model.dart';
import 'package:en_passant/widgets/coach/move_quality_badge.dart';

class MoveFeedbackCard extends StatelessWidget {
  final MoveReviewModel review;
  final bool overlay;

  const MoveFeedbackCard({
    super.key,
    required this.review,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = review.color;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, overlay ? -18 * (1 - value) : 10 * (1 - value)),
            child: Transform.scale(
              scale: overlay ? 0.94 + value * 0.06 : 1,
              child: child,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(overlay ? 22 : 18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: overlay ? 310 : 520),
            padding: EdgeInsets.all(overlay ? 12 : 14),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: overlay ? 0.84 : 0.64),
              borderRadius: BorderRadius.circular(overlay ? 22 : 18),
              border: Border.all(color: color.withValues(alpha: 0.42)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: overlay ? 0.26 : 0.12),
                  blurRadius: overlay ? 26 : 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (overlay
                                ? AppTextStyles.body2(context)
                                : AppTextStyles.textTheme().titleMedium)
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MoveQualityBadge(quality: review.quality),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  overlay ? review.suggestion : review.feedback,
                  maxLines: overlay ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2(context).copyWith(
                    color: AppColors.onSurface,
                    height: 1.35,
                  ),
                ),
                if (!overlay) ...[
                  const SizedBox(height: 8),
                  Text(
                    review.suggestion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(context).copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
