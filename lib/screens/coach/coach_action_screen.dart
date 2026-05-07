import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/coach_insight_model.dart';
import 'package:en_passant/models/match_model.dart';
import 'package:en_passant/providers/match_history_provider.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';

class CoachActionScreen extends StatelessWidget {
  final CoachInsightModel insight;

  const CoachActionScreen({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppScaffold.transparentAppBar(title: 'COACH ACTION'),
      body: Consumer<MatchHistoryProvider>(
        builder: (context, history, child) {
          final matches = history.matches;

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _ActionHeader(insight: insight),
              const SizedBox(height: 16),
              if (history.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (history.errorMessage != null)
                _MessagePanel(
                  icon: Icons.cloud_off_rounded,
                  title: 'Match history unavailable',
                  message: history.errorMessage!,
                )
              else if (matches.isEmpty)
                const _MessagePanel(
                  icon: Icons.history_rounded,
                  title: 'No saved matches yet',
                  message:
                      'Complete a match and this action will fill with your own games.',
                )
              else
                _ActionBody(insight: insight, matches: matches),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 18),
            ],
          );
        },
      ),
    );
  }
}

class _ActionBody extends StatelessWidget {
  final CoachInsightModel insight;
  final List<MatchModel> matches;

  const _ActionBody({
    required this.insight,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final action = insight.actionLabel.toLowerCase();
    final title = insight.title.toLowerCase();

    if (action.contains('loss') || title.contains('loss')) {
      return _LossReview(matches: matches, phase: _phaseFromTitle(title));
    }

    if (action.contains('first') ||
        action.contains('opening') ||
        insight.category == CoachInsightCategory.openings) {
      return _FirstMoveComparison(matches: matches);
    }

    if (insight.category == CoachInsightCategory.pacing ||
        insight.category == CoachInsightCategory.timeManagement ||
        action.contains('clock') ||
        action.contains('slow') ||
        action.contains('pause')) {
      return _PaceStudy(matches: matches);
    }

    return _MatchStudy(
      matches: _matchesForCategory(matches, insight.category),
      emptyMessage: 'No saved games match this recommendation yet.',
      heading: _categoryHeading(insight.category),
    );
  }

  String _phaseFromTitle(String title) {
    if (title.contains('opening')) return 'opening';
    if (title.contains('middlegame')) return 'middlegame';
    if (title.contains('endgame')) return 'endgame';
    return '';
  }

  List<MatchModel> _matchesForCategory(
    List<MatchModel> matches,
    CoachInsightCategory category,
  ) {
    switch (category) {
      case CoachInsightCategory.defense:
        return _sorted(matches.where((match) => match.defenseScore < 0.45));
      case CoachInsightCategory.aggression:
        return _sorted(matches.where((match) => match.aggressionScore >= 0.45));
      case CoachInsightCategory.difficulty:
        return _sorted(matches.where((match) => match.aiDifficulty > 0));
      case CoachInsightCategory.performance:
      case CoachInsightCategory.endgame:
        return _sorted(
            matches.where((match) => match.result == MatchResult.loss));
      case CoachInsightCategory.openings:
      case CoachInsightCategory.pacing:
      case CoachInsightCategory.timeManagement:
        return _sorted(matches);
    }
  }

  String _categoryHeading(CoachInsightCategory category) {
    switch (category) {
      case CoachInsightCategory.defense:
        return 'King Safety Study';
      case CoachInsightCategory.aggression:
        return 'Attack Timing Study';
      case CoachInsightCategory.difficulty:
        return 'Difficulty Samples';
      case CoachInsightCategory.endgame:
        return 'Endgame Loss Review';
      case CoachInsightCategory.performance:
      case CoachInsightCategory.openings:
      case CoachInsightCategory.pacing:
      case CoachInsightCategory.timeManagement:
        return 'Relevant Matches';
    }
  }
}

class _ActionHeader extends StatelessWidget {
  final CoachInsightModel insight;

  const _ActionHeader({required this.insight});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(insight.category);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  insight.actionLabel,
                  style: AppTextStyles.textTheme().titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight.title,
            style: AppTextStyles.headline3(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            insight.message,
            style: AppTextStyles.body2(context).copyWith(
              color: AppColors.onSurface,
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _LossReview extends StatelessWidget {
  final List<MatchModel> matches;
  final String phase;

  const _LossReview({
    required this.matches,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final losses = _sorted(
      matches.where(
        (match) =>
            match.result == MatchResult.loss &&
            (phase.isEmpty || match.lossPhase == phase),
      ),
    );

    if (losses.isEmpty) {
      return const _MessagePanel(
        icon: Icons.check_circle_rounded,
        title: 'No matching losses saved',
        message: 'Recent saved games do not contain this loss pattern yet.',
      );
    }

    return _MatchStudy(
      matches: losses,
      heading: phase.isEmpty ? 'Recent Losses' : '${_capitalize(phase)} Losses',
      emptyMessage: 'No losses to review.',
    );
  }
}

class _FirstMoveComparison extends StatelessWidget {
  final List<MatchModel> matches;

  const _FirstMoveComparison({required this.matches});

  @override
  Widget build(BuildContext context) {
    final whiteMatches =
        matches.where((match) => match.playerColor == 'White').toList();
    final blackMatches =
        matches.where((match) => match.playerColor == 'Black').toList();
    final withMoves = _sorted(
      matches.where((match) => match.moveHistory.isNotEmpty),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: _ColorSummary(label: 'White', matches: whiteMatches)),
            const SizedBox(width: 10),
            Expanded(
                child: _ColorSummary(label: 'Black', matches: blackMatches)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'First 12 Moves',
          style: AppTextStyles.textTheme().titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        if (withMoves.isEmpty)
          const _MessagePanel(
            icon: Icons.account_tree_rounded,
            title: 'Move records are still empty',
            message:
                'New completed games will save move history for this comparison.',
          )
        else
          ...withMoves.take(6).map(
                (match) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MovePreviewCard(match: match),
                ),
              ),
      ],
    );
  }
}

class _PaceStudy extends StatelessWidget {
  final List<MatchModel> matches;

  const _PaceStudy({required this.matches});

  @override
  Widget build(BuildContext context) {
    final timedMatches = matches
        .where((match) => match.averageMoveSeconds > 0)
        .toList()
      ..sort((a, b) => a.averageMoveSeconds.compareTo(b.averageMoveSeconds));
    final quickMatches =
        timedMatches.where((match) => match.averageMoveSeconds < 7).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TrainingChecklist(
          title: 'Tactical Pause Checklist',
          items: const [
            'Look for checks, captures, and direct threats.',
            'Recheck hanging pieces before moving quickly.',
            'Spend extra time when a king or passed pawn is exposed.',
          ],
        ),
        const SizedBox(height: 16),
        _MatchStudy(
          matches: quickMatches.isEmpty ? timedMatches : quickMatches,
          heading: quickMatches.isEmpty ? 'Timed Samples' : 'Fastest Games',
          emptyMessage: 'No timed match pace data has been saved yet.',
        ),
      ],
    );
  }
}

class _TrainingChecklist extends StatelessWidget {
  final String title;
  final List<String> items;

  const _TrainingChecklist({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.textTheme().titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.body2(context).copyWith(
                        color: AppColors.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchStudy extends StatelessWidget {
  final List<MatchModel> matches;
  final String heading;
  final String emptyMessage;

  const _MatchStudy({
    required this.matches,
    required this.heading,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return _MessagePanel(
        icon: Icons.search_rounded,
        title: heading,
        message: emptyMessage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: AppTextStyles.textTheme().titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        ...matches.take(8).map(
              (match) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MatchStudyCard(match: match),
              ),
            ),
      ],
    );
  }
}

class _ColorSummary extends StatelessWidget {
  final String label;
  final List<MatchModel> matches;

  const _ColorSummary({
    required this.label,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final wins =
        matches.where((match) => match.result == MatchResult.win).length;
    final rate = matches.isEmpty ? 0 : (wins / matches.length * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$rate%',
            style: AppTextStyles.headline3(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${matches.length} games',
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovePreviewCard extends StatelessWidget {
  final MatchModel match;

  const _MovePreviewCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MatchTitleRow(match: match),
          const SizedBox(height: 10),
          Text(
            _movePreview(match.moveHistory),
            style: AppTextStyles.monoCode(context).copyWith(
              color: AppColors.onSurface,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchStudyCard extends StatelessWidget {
  final MatchModel match;

  const _MatchStudyCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MatchTitleRow(match: match),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                  label: 'Phase',
                  value: match.lossPhase.isEmpty ? 'n/a' : match.lossPhase),
              _MetricChip(label: 'Opening', value: match.openingFamily),
              _MetricChip(
                label: 'Avg move',
                value: match.averageMoveSeconds == 0
                    ? 'n/a'
                    : '${match.averageMoveSeconds.toStringAsFixed(1)}s',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchTitleRow extends StatelessWidget {
  final MatchModel match;

  const _MatchTitleRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final color = _resultColor(match.result);
    return Row(
      children: [
        Icon(_resultIcon(match.result), color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${_resultLabel(match.result)} as ${match.playerColor}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textTheme().titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        Text(
          '${match.moveCount} moves',
          style: AppTextStyles.caption(context).copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.caption(context).copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final Widget child;

  const _BaseCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.16)),
      ),
      child: child,
    );
  }
}

class _MessagePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _MessagePanel({
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.textTheme().titleMedium?.copyWith(
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
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

List<MatchModel> _sorted(Iterable<MatchModel> matches) {
  return matches.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
}

String _movePreview(List<String> history) {
  return history.take(12).map(_moveLabel).join('  ');
}

String _moveLabel(String encoded) {
  final parts = encoded.split('-');
  if (parts.length < 2) return encoded;
  final from = int.tryParse(parts[0]);
  final to = int.tryParse(parts[1]);
  if (from == null || to == null) return encoded;
  return '${_squareName(from)}-${_squareName(to)}';
}

String _squareName(int index) {
  const files = 'abcdefgh';
  if (index < 0 || index > 63) return '?';
  final file = files[index % 8];
  final rank = 8 - (index ~/ 8);
  return '$file$rank';
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

Color _categoryColor(CoachInsightCategory category) {
  switch (category) {
    case CoachInsightCategory.openings:
      return AppColors.secondary;
    case CoachInsightCategory.pacing:
    case CoachInsightCategory.timeManagement:
      return AppColors.primaryLight;
    case CoachInsightCategory.defense:
      return AppColors.primary;
    case CoachInsightCategory.aggression:
      return AppColors.accent;
    case CoachInsightCategory.endgame:
      return AppColors.secondaryLight;
    case CoachInsightCategory.difficulty:
    case CoachInsightCategory.performance:
      return AppColors.highlight;
  }
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
