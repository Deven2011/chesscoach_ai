import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/move_review_model.dart';
import 'package:en_passant/providers/replay_provider.dart';

class MoveTimeline extends StatelessWidget {
  const MoveTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReplayProvider>(
      builder: (context, replay, child) {
        if (replay.timeline.isEmpty) {
          return _EmptyTimeline();
        }

        return SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, index) {
              final entry = replay.timeline[index];
              final selected =
                  replay.state.currentMoveIndex == entry.moveNumber;
              final color = _qualityColor(entry.quality);
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => replay.jumpToMove(entry.moveNumber),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 92,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.2)
                        : AppColors.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? color.withValues(alpha: 0.72)
                          : AppColors.border.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'M${entry.moveNumber}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.monoCode(context).copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.notation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: replay.timeline.length,
          ),
        );
      },
    );
  }

  Color _qualityColor(MoveQuality? quality) {
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
      case null:
        return AppColors.onSurfaceVariant;
    }
  }
}

class _EmptyTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'No moves available for replay yet.',
        style: AppTextStyles.body2(context),
      ),
    );
  }
}
