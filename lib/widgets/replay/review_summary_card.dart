import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/game_review_model.dart';

class ReviewSummaryCard extends StatelessWidget {
  final GameReviewModel review;

  const ReviewSummaryCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AccuracyRing(accuracy: review.accuracy),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.textTheme().titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${review.moveCount} moves | ${review.bestMoveStreak} best streak',
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Metric(label: 'Blunders', value: '${review.blunders}'),
              _Metric(label: 'Mistakes', value: '${review.mistakes}'),
              _Metric(label: 'Brilliant', value: '${review.brilliantMoves}'),
              _Metric(label: 'Strongest', value: review.strongestPhase),
              _Metric(label: 'Weakest', value: review.weakestPhase),
            ],
          ),
          const SizedBox(height: 14),
          ...review.coachSummary.map(
            (summary) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                summary,
                style: AppTextStyles.body2(context).copyWith(
                  color: AppColors.onSurface,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyRing extends StatelessWidget {
  final int accuracy;

  const _AccuracyRing({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: accuracy / 100,
            strokeWidth: 7,
            backgroundColor: AppColors.surfaceDark,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
          Center(
            child: Text(
              '$accuracy%',
              style: AppTextStyles.monoCode(context).copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.caption(context).copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
