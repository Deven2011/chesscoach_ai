import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/coach_insight_model.dart';
import 'package:en_passant/providers/ai_coach_provider.dart';
import 'package:en_passant/screens/coach/coach_action_screen.dart';
import 'package:en_passant/widgets/coach/coach_insight_card.dart';
import 'package:en_passant/widgets/coach/improvement_tile.dart';
import 'package:en_passant/widgets/coach/performance_summary_card.dart';
import 'package:en_passant/widgets/coach/recommendation_card.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';

class AiCoachDashboardScreen extends StatelessWidget {
  const AiCoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppScaffold.transparentAppBar(title: 'AI COACH'),
      body: Consumer<AiCoachProvider>(
        builder: (context, provider, child) {
          final report = provider.report;

          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: AppColors.primary,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                PerformanceSummaryCard(
                  summary: report.summary,
                  isSyncing: provider.isSaving,
                ),
                const SizedBox(height: 18),
                if (provider.errorMessage != null)
                  _ErrorBanner(message: provider.errorMessage!),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (report.patterns.totalMatches == 0)
                  const _CoachEmptyState()
                else ...[
                  _Section(
                    title: 'Personalized Insights',
                    subtitle:
                        'Highest-priority interpretations from your games',
                    child: _InsightList(insights: provider.insights),
                  ),
                  _Section(
                    title: 'Recommended Improvements',
                    subtitle:
                        'Rule-based training plan that updates after games',
                    child: _RecommendationGrid(
                      recommendations: provider.recommendations,
                    ),
                  ),
                  _Section(
                    title: 'Gameplay Tendencies',
                    subtitle: 'How your pacing and risk profile are evolving',
                    child: _InsightList(insights: provider.tendencies),
                  ),
                  _Section(
                    title: 'Strengths & Weaknesses',
                    subtitle:
                        'Use strengths as anchors and weaknesses as drills',
                    child: _StrengthWeaknessList(
                      strengths: provider.strengths,
                      weaknesses: provider.weaknesses,
                    ),
                  ),
                  _Section(
                    title: 'Recent Performance Trends',
                    subtitle:
                        'Live read on current form and difficulty comfort',
                    child: _TrendPanel(provider: provider),
                  ),
                ],
                SizedBox(height: MediaQuery.paddingOf(context).bottom + 18),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InsightList extends StatelessWidget {
  final List<CoachInsightModel> insights;

  const _InsightList({required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const _PlaceholderPanel(
        icon: Icons.auto_awesome_rounded,
        title: 'More games needed',
        message:
            'This section unlocks after ChessCoach AI sees a clearer pattern.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < insights.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CoachInsightCard(
              insight: insights[index],
              index: index,
              onAction: () => _openCoachAction(context, insights[index]),
            ),
          ),
      ],
    );
  }
}

class _RecommendationGrid extends StatelessWidget {
  final List<CoachInsightModel> recommendations;

  const _RecommendationGrid({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const _PlaceholderPanel(
        icon: Icons.tips_and_updates_rounded,
        title: 'Training plan pending',
        message:
            'Recommendations appear as soon as match history is available.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: recommendations
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RecommendationCard(
                      recommendation: item,
                      onAction: () => _openCoachAction(context, item),
                    ),
                  ),
                )
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.58,
          children: recommendations
              .map(
                (item) => RecommendationCard(
                  recommendation: item,
                  onAction: () => _openCoachAction(context, item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

void _openCoachAction(BuildContext context, CoachInsightModel insight) {
  Navigator.of(context).push(
    AppScaffold.pageRoute(
      child: CoachActionScreen(insight: insight),
    ),
  );
}

class _StrengthWeaknessList extends StatelessWidget {
  final List<CoachInsightModel> strengths;
  final List<CoachInsightModel> weaknesses;

  const _StrengthWeaknessList({
    required this.strengths,
    required this.weaknesses,
  });

  @override
  Widget build(BuildContext context) {
    final items = [...strengths.take(2), ...weaknesses.take(2)];
    if (items.isEmpty) {
      return const _PlaceholderPanel(
        icon: Icons.balance_rounded,
        title: 'Profile still balancing',
        message: 'Play more games to separate repeatable strengths from leaks.',
      );
    }

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ImprovementTile(insight: item),
            ),
          )
          .toList(),
    );
  }
}

class _TrendPanel extends StatelessWidget {
  final AiCoachProvider provider;

  const _TrendPanel({required this.provider});

  @override
  Widget build(BuildContext context) {
    final patterns = provider.report.patterns;
    final difficulty = patterns.mostSuccessfulDifficulty == 0
        ? 'Not enough AI games'
        : 'Level ${patterns.mostSuccessfulDifficulty}';
    final opening = patterns.bestOpening.isEmpty
        ? 'Opening baseline pending'
        : patterns.bestOpening;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 620 ? 3 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 3.2 : 1.45,
          children: [
            _TrendMetric(
              icon: Icons.show_chart_rounded,
              label: 'Recent Form',
              value: _trendLabel(patterns.trendDelta),
              color: patterns.trendDelta >= 0
                  ? AppColors.primary
                  : AppColors.error,
            ),
            _TrendMetric(
              icon: Icons.psychology_rounded,
              label: 'Best Difficulty',
              value: difficulty,
              color: AppColors.secondary,
            ),
            _TrendMetric(
              icon: Icons.account_tree_rounded,
              label: 'Opening Signal',
              value: opening,
              color: AppColors.accent,
            ),
          ],
        );
      },
    );
  }

  String _trendLabel(double delta) {
    if (delta == 0) return 'Stable';
    final points = (delta * 100).round();
    return points > 0 ? '+$points pts' : '$points pts';
  }
}

class _TrendMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TrendMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
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

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.textTheme().titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _CoachEmptyState extends StatelessWidget {
  const _CoachEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 18),
      child: _PlaceholderPanel(
        icon: Icons.psychology_alt_rounded,
        title: 'Your coach is waiting for game data',
        message:
            'Finish a match to generate insights for color performance, AI difficulty, pacing, openings, streaks, and game phases.',
      ),
    );
  }
}

class _PlaceholderPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _PlaceholderPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 38),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headline3(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body2(context).copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      child: Text(
        message,
        style: AppTextStyles.body2(context).copyWith(color: AppColors.error),
      ),
    );
  }
}
