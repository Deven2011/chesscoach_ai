import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Consumer<AppModel>(
      builder: (context, appModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0 * scale),
              child: Text(
                'Your Stats',
                style: AppTextStyles.headline2(context).copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0 * scale),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                  // Taller aspect ratio for stat cards to prevent text clipping
                  final childAspectRatio =
                      (constraints.maxWidth / crossAxisCount) / (140 * scale);

                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: AppScaffold.cardSpacing,
                      mainAxisSpacing: AppScaffold.cardSpacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    children: [
                      StatCard(
                        title: 'Win Rate',
                        value: '${_calculateWinRate(appModel)}%',
                        icon: Icons.insights_rounded,
                        color: AppColors.primary,
                      ),
                      StatCard(
                        title: 'Current Streak',
                        value: '${appModel.currentStreak}',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.secondary,
                      ),
                      StatCard(
                        title: 'AI Level',
                        value: _getDifficultyName(appModel.aiDifficulty),
                        icon: Icons.psychology_rounded,
                        color: AppColors.accent,
                      ),
                      StatCard(
                        title: 'Games',
                        value: '${appModel.gamesPlayed}',
                        icon: Icons.history_edu_rounded,
                        color: AppColors.primaryLight,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  int _calculateWinRate(AppModel appModel) {
    if (appModel.gamesPlayed == 0) return 0;
    return ((appModel.gamesWon / appModel.gamesPlayed) * 100).round();
  }

  String _getDifficultyName(int difficulty) {
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
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Subtle icon in background
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 60 * scale,
              color: color.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6 * scale),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18 * scale,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: AppTextStyles.headline3(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 22 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColors.onSurfaceVariant.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 10 * scale,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
