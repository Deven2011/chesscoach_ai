import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/coach_insight_model.dart';

class RecommendationCard extends StatelessWidget {
  final CoachInsightModel recommendation;

  const RecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    final color =
        recommendation.isPositive ? AppColors.primary : AppColors.accent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.64),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _categoryIcon(recommendation.category),
                    color: color,
                    size: 22 * scale,
                  ),
                  SizedBox(width: 9 * scale),
                  Expanded(
                    child: Text(
                      recommendation.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.textTheme().titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10 * scale),
              Text(
                recommendation.message,
                style: AppTextStyles.body2(context).copyWith(
                  color: AppColors.onSurface,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12 * scale),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recommendation.actionLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(context).copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (recommendation.metricValue.isNotEmpty)
                    Text(
                      recommendation.metricValue,
                      style: AppTextStyles.monoCode(context).copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(CoachInsightCategory category) {
    switch (category) {
      case CoachInsightCategory.openings:
        return Icons.account_tree_rounded;
      case CoachInsightCategory.pacing:
        return Icons.speed_rounded;
      case CoachInsightCategory.defense:
        return Icons.shield_rounded;
      case CoachInsightCategory.aggression:
        return Icons.bolt_rounded;
      case CoachInsightCategory.timeManagement:
        return Icons.timer_rounded;
      case CoachInsightCategory.endgame:
        return Icons.flag_rounded;
      case CoachInsightCategory.difficulty:
        return Icons.psychology_rounded;
      case CoachInsightCategory.performance:
        return Icons.query_stats_rounded;
    }
  }
}
