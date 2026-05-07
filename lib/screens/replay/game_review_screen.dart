import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/move_review_model.dart';
import 'package:en_passant/providers/replay_provider.dart';
import 'package:en_passant/widgets/replay/critical_moment_card.dart';
import 'package:en_passant/widgets/replay/evaluation_graph.dart';
import 'package:en_passant/widgets/replay/review_summary_card.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';

class GameReviewScreen extends StatelessWidget {
  const GameReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReplayProvider>(
      builder: (context, replay, child) {
        final review = replay.review;
        return AppScaffold(
          padding: EdgeInsets.zero,
          appBar: AppScaffold.transparentAppBar(
            title: 'POST-GAME REVIEW',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: ReviewSummaryCard(review: review),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: EvaluationGraph()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _QualityDistribution(
                    distribution: review.qualityDistribution,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: CriticalMomentCard(
                    review: review.criticalMistake,
                    onTap: () {
                      final move = review.criticalMistake?.moveNumber;
                      if (move != null) replay.jumpToMove(move);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).padding.bottom + 20,
                ),
                sliver: SliverToBoxAdapter(
                  child: _TurningPoints(
                    points: review.turningPoints,
                    onTap: (move) {
                      replay.jumpToMove(move);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QualityDistribution extends StatelessWidget {
  final Map<MoveQuality, int> distribution;

  const _QualityDistribution({required this.distribution});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Move Quality Breakdown',
            style: AppTextStyles.textTheme().titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MoveQuality.values.map((quality) {
              return Chip(
                backgroundColor: AppColors.surfaceDark,
                side: BorderSide(color: _color(quality).withValues(alpha: 0.3)),
                label: Text(
                  '${quality.name}: ${distribution[quality] ?? 0}',
                  style: AppTextStyles.caption(context).copyWith(
                    color: _color(quality),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
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
}

class _TurningPoints extends StatelessWidget {
  final List<MoveReviewModel> points;
  final void Function(int moveNumber) onTap;

  const _TurningPoints({
    required this.points,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Turning Points',
            style: AppTextStyles.textTheme().titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          if (points.isEmpty)
            Text(
              'No major turning points were detected.',
              style: AppTextStyles.body2(context),
            )
          else
            ...points.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CriticalMomentCard(
                  review: point,
                  onTap: () => onTap(point.moveNumber),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
