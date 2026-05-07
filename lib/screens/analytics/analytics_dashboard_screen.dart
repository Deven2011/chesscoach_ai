import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/providers/analytics_provider.dart';
import 'package:en_passant/widgets/analytics/analytics_chart.dart';
import 'package:en_passant/widgets/analytics/insight_card.dart';
import 'package:en_passant/widgets/analytics/recent_match_tile.dart';
import 'package:en_passant/widgets/analytics/stat_card.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppScaffold.transparentAppBar(title: 'ANALYTICS'),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          final analytics = provider.analytics;

          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: AppColors.primary,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                _Header(analytics: analytics),
                const SizedBox(height: 20),
                if (provider.errorMessage != null)
                  _ErrorBanner(message: provider.errorMessage!),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (analytics.totalMatches == 0)
                  const _EmptyAnalytics()
                else ...[
                  _StatsGrid(analytics: analytics),
                  const SizedBox(height: 18),
                  AnalyticsChart(analytics: analytics),
                  const SizedBox(height: 18),
                  _InsightsSection(analytics: analytics),
                  const SizedBox(height: 18),
                  _RecentMatchesSection(analytics: analytics),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AnalyticsModel analytics;

  const _Header({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.22),
              AppColors.secondary.withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.analytics_rounded,
              color: AppColors.secondary,
              size: 36,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Center',
                    style: AppTextStyles.headline3(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${analytics.totalMatches} tracked matches',
                    style: AppTextStyles.body2(context).copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AnalyticsModel analytics;

  const _StatsGrid({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 620 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 4 ? 1.0 : 0.92,
          children: [
            StatCard(
              title: 'Win Rate',
              value: '${(analytics.winRate * 100).round()}%',
              subtitle: '${analytics.wins} wins',
              icon: Icons.trending_up_rounded,
              color: AppColors.primary,
            ),
            StatCard(
              title: 'Current Streak',
              value: '${analytics.currentStreak}',
              subtitle: 'wins in a row',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.secondary,
            ),
            StatCard(
              title: 'Avg Duration',
              value: _duration(analytics.averageDuration),
              subtitle: 'per match',
              icon: Icons.timer_rounded,
              color: AppColors.accent,
            ),
            StatCard(
              title: 'Matches',
              value: '${analytics.totalMatches}',
              subtitle: '${analytics.draws} draws',
              icon: Icons.history_edu_rounded,
              color: AppColors.primaryLight,
            ),
          ],
        );
      },
    );
  }

  String _duration(Duration duration) {
    if (duration.inHours > 0) return '${duration.inHours}h';
    return '${duration.inMinutes}m';
  }
}

class _InsightsSection extends StatelessWidget {
  final AnalyticsModel analytics;

  const _InsightsSection({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Personalized Insights',
      children: analytics.insights
          .map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InsightCard(insight: insight),
              ))
          .toList(),
    );
  }
}

class _RecentMatchesSection extends StatelessWidget {
  final AnalyticsModel analytics;

  const _RecentMatchesSection({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Recent Matches',
      children: analytics.recentMatches
          .map((match) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecentMatchTile(match: match),
              ))
          .toList(),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.textTheme().titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _EmptyAnalytics extends StatelessWidget {
  const _EmptyAnalytics();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.query_stats_rounded,
            color: AppColors.secondary,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            'No analytics yet',
            style: AppTextStyles.headline3(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a match to start tracking win rate, streaks, duration, and AI difficulty performance.',
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
