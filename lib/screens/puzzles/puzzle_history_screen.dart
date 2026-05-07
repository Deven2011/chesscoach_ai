import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/puzzle_progress_model.dart';
import 'package:en_passant/widgets/puzzles/tactical_theme_badge.dart';

/// Screen showing user's puzzle history and analytics
class PuzzleHistoryScreen extends StatefulWidget {
  final PuzzleProgressModel progress;

  const PuzzleHistoryScreen({
    Key? key,
    required this.progress,
  }) : super(key: key);

  @override
  State<PuzzleHistoryScreen> createState() => _PuzzleHistoryScreenState();
}

class _PuzzleHistoryScreenState extends State<PuzzleHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Analytics'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Statistics'),
            Tab(text: 'Themes'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStatisticsTab(),
            _buildThemesTab(),
            _buildCategoriesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overview cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildStatCard(
                'Puzzles Solved',
                widget.progress.totalPuzzlesSolved.toString(),
                Icons.done_all,
                AppColors.primary,
              ),
              _buildStatCard(
                'Accuracy',
                '${widget.progress.solveAccuracy.toStringAsFixed(1)}%',
                Icons.precision_manufacturing,
                AppColors.secondary,
              ),
              _buildStatCard(
                'Current Streak',
                widget.progress.currentStreak.toString(),
                Icons.local_fire_department,
                AppColors.accent,
              ),
              _buildStatCard(
                'Best Streak',
                widget.progress.longestStreak.toString(),
                Icons.emoji_events,
                AppColors.primaryLight,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Detailed stats
          _buildDetailedStats(),
          const SizedBox(height: 24),

          // Tier progress
          _buildTierProgress(),
        ],
      ),
    );
  }

  Widget _buildThemesTab() {
    if (widget.progress.themeStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.extension_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No puzzle data yet',
              style: AppTextStyles.textTheme().bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    final sorted = widget.progress.themeStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final entry = sorted[index];
        final percentage =
            (entry.value / widget.progress.totalPuzzlesSolved) * 100;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TacticalThemeBadge(
            theme: entry.key,
            count: entry.value,
            percentage: percentage,
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    if (widget.progress.categoryStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No category data yet',
              style: AppTextStyles.textTheme().bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    final sorted = widget.progress.categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final entry = sorted[index];
        final percentage =
            (entry.value / widget.progress.totalPuzzlesSolved) * 100;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: AppTextStyles.textTheme().bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${entry.value} solved',
                      style: AppTextStyles.textTheme().bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.textTheme().labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.textTheme().headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.textTheme().labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Details',
            style: AppTextStyles.textTheme().labelLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Average Solve Time',
            _formatDuration(
                Duration(seconds: widget.progress.averageSolveTime)),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Total Time Spent',
            _formatDuration(widget.progress.totalTimeSpent),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Correct Solutions',
            '${widget.progress.correctSolutions} / ${widget.progress.totalPuzzlesSolved}',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Hints Used',
            widget.progress.hintsUsed.toString(),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Total XP Earned',
            widget.progress.totalXpEarned.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.textTheme().bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: AppTextStyles.textTheme().bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTierProgress() {
    // Simple tier display
    final tierName = _getTierName(widget.progress.totalXpEarned);
    final tierIcon = _getTierIcon(tierName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Current Tier',
            style: AppTextStyles.textTheme().labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            tierIcon,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            tierName,
            style: AppTextStyles.textTheme().headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _getTierName(int xp) {
    if (xp < 500) return 'Novice';
    if (xp < 1500) return 'Beginner';
    if (xp < 3500) return 'Intermediate';
    if (xp < 7000) return 'Advanced';
    if (xp < 12000) return 'Expert';
    if (xp < 20000) return 'Master';
    return 'Grandmaster';
  }

  String _getTierIcon(String tier) {
    switch (tier) {
      case 'Novice':
        return '🌱';
      case 'Beginner':
        return '📚';
      case 'Intermediate':
        return '⚔️';
      case 'Advanced':
        return '🎯';
      case 'Expert':
        return '👑';
      case 'Master':
        return '🏆';
      case 'Grandmaster':
        return '♛';
      default:
        return '🎮';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${(duration.inMinutes % 60)}m';
    }
  }
}
