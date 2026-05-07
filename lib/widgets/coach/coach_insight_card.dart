import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/coach_insight_model.dart';

class CoachInsightCard extends StatelessWidget {
  final CoachInsightModel insight;
  final int index;
  final VoidCallback? onAction;

  const CoachInsightCard({
    super.key,
    required this.insight,
    this.index = 0,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(insight.category);
    final scale = AppTextStyles.responsiveScale(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.26)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42 * scale,
                  height: 42 * scale,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_kindIcon(insight.kind), color: color),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              insight.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.textTheme()
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          if (insight.metricValue.isNotEmpty) ...[
                            SizedBox(width: 8 * scale),
                            _MetricPill(
                              label: insight.metricValue,
                              color: color,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        insight.message,
                        style: AppTextStyles.body2(context).copyWith(
                          color: AppColors.onSurface,
                          height: 1.4,
                        ),
                      ),
                      if (insight.actionLabel.isNotEmpty) ...[
                        SizedBox(height: 10 * scale),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: onAction,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(insight.actionLabel),
                            style: TextButton.styleFrom(
                              foregroundColor: color,
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 4,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle:
                                  AppTextStyles.caption(context).copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _kindIcon(CoachInsightKind kind) {
    switch (kind) {
      case CoachInsightKind.recommendation:
        return Icons.tips_and_updates_rounded;
      case CoachInsightKind.tendency:
        return Icons.radar_rounded;
      case CoachInsightKind.strength:
        return Icons.workspace_premium_rounded;
      case CoachInsightKind.weakness:
        return Icons.report_problem_rounded;
      case CoachInsightKind.trend:
        return Icons.trending_up_rounded;
      case CoachInsightKind.summary:
      case CoachInsightKind.insight:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _categoryColor(CoachInsightCategory category) {
    switch (category) {
      case CoachInsightCategory.openings:
        return AppColors.secondary;
      case CoachInsightCategory.pacing:
      case CoachInsightCategory.timeManagement:
        return AppColors.primaryLight;
      case CoachInsightCategory.defense:
        return AppColors.primary;
      case CoachInsightCategory.aggression:
        return AppColors.accent;
      case CoachInsightCategory.endgame:
        return AppColors.secondaryLight;
      case CoachInsightCategory.difficulty:
      case CoachInsightCategory.performance:
        return AppColors.highlight;
    }
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption(context).copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
