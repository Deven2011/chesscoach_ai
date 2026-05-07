import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/player.dart';
import 'package:en_passant/widgets/main_menu_view/game_options/ai_difficulty_picker.dart';
import 'package:en_passant/widgets/main_menu_view/game_options/game_mode_picker.dart';
import 'package:en_passant/widgets/main_menu_view/game_options/side_picker.dart';
import 'package:en_passant/widgets/main_menu_view/game_options/time_limit_picker.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/core/theme/app_colors.dart';

class GameOptions extends StatefulWidget {
  const GameOptions({super.key});

  @override
  State<GameOptions> createState() => _GameOptionsState();
}

class _GameOptionsState extends State<GameOptions>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    final appModel = context.watch<AppModel>();

    return FadeTransition(
      opacity: _animationController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SetupSummary(appModel: appModel),
          SizedBox(height: 24 * scale),
          SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero)
                    .animate(
              CurvedAnimation(
                  parent: _animationController, curve: Curves.easeOut),
            ),
            child: GameModePicker(
              appModel.gameModeSelection,
              appModel.setGameMode,
            ),
          ),
          SizedBox(height: 24 * scale),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutQuart,
            switchOutCurve: Curves.easeInQuart,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: appModel.playingWithAI
                ? Column(
                    key: const ValueKey('ai-options'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-0.1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve:
                                const Interval(0.1, 0.9, curve: Curves.easeOut),
                          ),
                        ),
                        child: AIDifficultyPicker(
                          appModel.aiDifficulty,
                          appModel.setAIDifficulty,
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-0.1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.15, 0.95,
                                curve: Curves.easeOut),
                          ),
                        ),
                        child: SidePicker(
                          appModel.selectedSide,
                          appModel.setPlayerSide,
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                    ],
                  )
                : Column(
                    key: const ValueKey('local-options'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SetupNotice(
                        icon: Icons.groups_2_rounded,
                        title: 'Local 2 Player',
                        message:
                            'White and Black share this device. Timers, move history, undo and redo remain active for the match.',
                      ),
                      SizedBox(height: 24 * scale),
                    ],
                  ),
          ),
          SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero)
                    .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: TimeLimitPicker(
              selectedTime: appModel.timeLimit,
              setTime: appModel.setTimeLimit,
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupSummary extends StatelessWidget {
  final AppModel appModel;

  const _SetupSummary({required this.appModel});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42 * scale,
            height: 42 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.9),
                  AppColors.primary.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Icon(
              appModel.playingAgainstCoach
                  ? Icons.psychology_alt_rounded
                  : appModel.playerCount == 1
                      ? Icons.smart_toy_rounded
                      : Icons.people_alt_rounded,
              color: Colors.white,
              size: 22 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appModel.playingAgainstCoach
                      ? 'Play Against Coach'
                      : appModel.playerCount == 1
                          ? 'AI Match'
                          : 'Local Match',
                  style: AppTextStyles.textTheme().titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  _summaryText(appModel),
                  style: AppTextStyles.textTheme().bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _summaryText(AppModel model) {
    final clock = model.timeLimit == 0 ? 'Unlimited' : '${model.timeLimit} min';
    if (model.playingAgainstCoach) {
      return 'Live move review, ${_difficulty(model.aiDifficulty)} AI, ${_side(model.selectedSide)}, $clock';
    }
    if (model.playerCount == 1) {
      return '${_difficulty(model.aiDifficulty)} AI, ${_side(model.selectedSide)}, $clock';
    }
    return 'Two players on one device, $clock';
  }

  String _difficulty(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      case 4:
        return 'Expert';
      case 5:
        return 'Master';
      default:
        return 'Custom';
    }
  }

  String _side(Player side) {
    switch (side) {
      case Player.player1:
        return 'White';
      case Player.player2:
        return 'Black';
      case Player.random:
        return 'Random side';
    }
  }
}

class _SetupNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _SetupNotice({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.secondary,
            size: 20 * scale,
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textTheme().titleSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  message,
                  style: AppTextStyles.textTheme().bodySmall?.copyWith(
                        color: AppColors.onSurface,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
