import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/move_review_model.dart';
import 'package:en_passant/providers/realtime_coach_provider.dart';
import 'package:en_passant/widgets/coach/move_feedback_card.dart';
import 'package:en_passant/widgets/coach/move_quality_badge.dart';

class CoachSidebar extends StatelessWidget {
  final bool isGameOver;

  const CoachSidebar({
    super.key,
    this.isGameOver = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RealtimeCoachProvider>(
      builder: (context, coach, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.psychology_alt_rounded,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Live Coach',
                          style:
                              AppTextStyles.textTheme().titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      Switch(
                        value: coach.coachModeEnabled,
                        activeColor: AppColors.primary,
                        onChanged: coach.setCoachModeEnabled,
                      ),
                    ],
                  ),
                  if (coach.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      coach.errorMessage!,
                      style: AppTextStyles.caption(context)
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _StatsRow(coach: coach),
                  const SizedBox(height: 12),
                  if (isGameOver)
                    _PostGameSummary(summary: coach.summary)
                  else if (coach.latestReview != null)
                    MoveFeedbackCard(review: coach.latestReview!)
                  else
                    _WaitingPanel(isAnalyzing: coach.isAnalyzing),
                  if (coach.reviews.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _MoveQualityHistory(reviews: coach.reviews),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  final RealtimeCoachProvider coach;

  const _StatsRow({required this.coach});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatPill(label: 'Accuracy', value: '${coach.accuracy}%'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(label: 'Streak', value: '${coach.bestMoveStreak}'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(label: 'Blunders', value: '${coach.blunderCount}'),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body2(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingPanel extends StatelessWidget {
  final bool isAnalyzing;

  const _WaitingPanel({required this.isAnalyzing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          if (isAnalyzing)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(Icons.lightbulb_rounded, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAnalyzing
                  ? 'Analyzing your move...'
                  : 'Make a move to receive live coach feedback.',
              style: AppTextStyles.body2(context).copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveQualityHistory extends StatelessWidget {
  final List<MoveReviewModel> reviews;

  const _MoveQualityHistory({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final visible = reviews.reversed.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Move Quality',
          style: AppTextStyles.caption(context).copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: visible
                .map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: MoveQualityBadge(
                      quality: review.quality,
                      compact: true,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _PostGameSummary extends StatelessWidget {
  final CoachGameSummary summary;

  const _PostGameSummary({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post-game Review',
            style: AppTextStyles.textTheme().titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accuracy ${summary.accuracy}% | ${summary.mistakes} mistakes | ${summary.blunders} blunders',
            style: AppTextStyles.body2(context).copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.criticalMistake == null
                ? summary.strengths.first
                : 'Critical moment: move ${summary.criticalMistake!.moveNumber}, ${summary.criticalMistake!.qualityLabel}.',
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.secondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
