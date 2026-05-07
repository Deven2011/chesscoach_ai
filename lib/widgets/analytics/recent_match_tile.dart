import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/models/match_model.dart';

class RecentMatchTile extends StatelessWidget {
  final MatchModel match;

  const RecentMatchTile({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    final color = _resultColor(match.result);

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42 * scale,
            height: 42 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(_resultIcon(match.result), color: color, size: 22),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_resultLabel(match.result)} • ${match.gameMode}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textTheme().titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  _subtitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            _dateLabel(match.timestamp),
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final difficulty = match.aiDifficulty > 0
        ? ' • ${AnalyticsModel.difficultyLabel(match.aiDifficulty)} AI'
        : '';
    return '${match.playerColor}$difficulty • ${match.moveCount} moves • ${_duration(match.duration)}';
  }

  String _duration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _dateLabel(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays}d ago';
  }

  Color _resultColor(MatchResult result) {
    switch (result) {
      case MatchResult.win:
        return AppColors.primary;
      case MatchResult.loss:
        return AppColors.error;
      case MatchResult.draw:
        return AppColors.secondary;
    }
  }

  IconData _resultIcon(MatchResult result) {
    switch (result) {
      case MatchResult.win:
        return Icons.emoji_events_rounded;
      case MatchResult.loss:
        return Icons.close_rounded;
      case MatchResult.draw:
        return Icons.horizontal_rule_rounded;
    }
  }

  String _resultLabel(MatchResult result) {
    switch (result) {
      case MatchResult.win:
        return 'Win';
      case MatchResult.loss:
        return 'Loss';
      case MatchResult.draw:
        return 'Draw';
    }
  }
}
