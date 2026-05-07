import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/providers/replay_provider.dart';

class ReplayControls extends StatelessWidget {
  const ReplayControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReplayProvider>(
      builder: (context, replay, child) {
        final state = replay.state;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _IconControl(
                    icon: Icons.first_page_rounded,
                    onPressed: state.canGoPrevious ? replay.goToStart : null,
                  ),
                  _IconControl(
                    icon: Icons.chevron_left_rounded,
                    onPressed: state.canGoPrevious ? replay.previousMove : null,
                  ),
                  _IconControl(
                    large: true,
                    icon: state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onPressed:
                        state.moves.isEmpty ? null : replay.togglePlayback,
                  ),
                  _IconControl(
                    icon: Icons.chevron_right_rounded,
                    onPressed: state.canGoNext ? replay.nextMove : null,
                  ),
                  _IconControl(
                    icon: Icons.last_page_rounded,
                    onPressed: state.canGoNext ? replay.goToEnd : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${state.currentMoveIndex}/${state.moves.length}',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.monoCode(context).copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Speed',
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: state.playbackSpeed,
                      min: 0.5,
                      max: 3,
                      divisions: 5,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.surfaceRaised,
                      onChanged: replay.setPlaybackSpeed,
                    ),
                  ),
                  Text(
                    '${state.playbackSpeed.toStringAsFixed(1)}x',
                    style: AppTextStyles.monoCode(context).copyWith(
                      color: AppColors.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconControl extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool large;

  const _IconControl({
    required this.icon,
    required this.onPressed,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: large
              ? AppColors.primary
              : AppColors.surfaceDark.withValues(alpha: 0.8),
          disabledBackgroundColor: AppColors.surfaceDark.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          minimumSize: Size.square(large ? 46 : 40),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
