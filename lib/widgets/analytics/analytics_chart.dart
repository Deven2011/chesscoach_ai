import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/analytics_model.dart';

class AnalyticsChart extends StatelessWidget {
  final AnalyticsModel analytics;

  const AnalyticsChart({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Difficulty Performance',
            style: AppTextStyles.textTheme().titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            'Win rate by level',
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 18 * scale),
          SizedBox(
            height: 210 * scale,
            child: analytics.difficultyPerformance.isEmpty
                ? const _EmptyChart()
                : BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.border.withValues(alpha: 0.24),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: 25,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}%',
                              style: AppTextStyles.caption(context).copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10 * scale,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: EdgeInsets.only(top: 8 * scale),
                              child: Text(
                                AnalyticsModel.difficultyLabel(value.toInt())
                                    .toUpperCase(),
                                style: AppTextStyles.caption(context).copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 9 * scale,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      barGroups: _groups(),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 450),
                    swapAnimationCurve: Curves.easeOutQuart,
                  ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _groups() {
    return analytics.difficultyPerformance.values.map((performance) {
      return BarChartGroupData(
        x: performance.difficulty,
        barRods: [
          BarChartRodData(
            toY: performance.winRate * 100,
            width: 18,
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ],
      );
    }).toList();
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Play AI matches to populate this chart.',
        textAlign: TextAlign.center,
        style: AppTextStyles.body2(context).copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
