import 'package:en_passant/ai_coach/gameplay_pattern_analyzer.dart';
import 'package:en_passant/models/coach_insight_model.dart';

class RecommendationEngine {
  const RecommendationEngine();

  List<CoachInsightModel> generate(GameplayPatternReport report) {
    if (report.totalMatches == 0) return _newUserRecommendations();

    final recommendations = <CoachInsightModel>[
      _openingRecommendation(report),
      _pacingRecommendation(report),
      _defenseRecommendation(report),
      _aggressionRecommendation(report),
      _timeManagementRecommendation(report),
    ];

    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    return recommendations;
  }

  List<CoachInsightModel> _newUserRecommendations() {
    return [
      CoachInsightModel.create(
        kind: CoachInsightKind.recommendation,
        category: CoachInsightCategory.openings,
        title: 'Build an opening baseline',
        message:
            'Play three games with the same first-move plan so ChessCoach AI can compare your results by opening family.',
        actionLabel: 'Repeat one opening idea',
        priority: 88,
        confidence: 0.7,
        metricLabel: 'Data needed',
        metricValue: '3 games',
      ),
      CoachInsightModel.create(
        kind: CoachInsightKind.recommendation,
        category: CoachInsightCategory.timeManagement,
        title: 'Track your natural pace',
        message:
            'Complete a few timed games to unlock fast-versus-slow performance coaching.',
        actionLabel: 'Play a timed match',
        priority: 72,
        confidence: 0.68,
        metricLabel: 'Current games',
        metricValue: '0',
      ),
    ];
  }

  CoachInsightModel _openingRecommendation(GameplayPatternReport report) {
    final bestOpening = report.bestOpening;
    final weakPhase = report.weakestPhase;
    if (bestOpening.isNotEmpty && report.openingWinRates[bestOpening]! >= 0.6) {
      return CoachInsightModel.create(
        kind: CoachInsightKind.recommendation,
        category: CoachInsightCategory.openings,
        title: 'Lean into $bestOpening',
        message:
            'Your strongest opening family is $bestOpening. Keep using it while adding one prepared response for early pressure.',
        actionLabel: 'Review first 10 moves',
        priority: 84,
        confidence: _confidence(report.totalMatches),
        metricLabel: 'Opening win rate',
        metricValue: _percent(report.openingWinRates[bestOpening]!),
      );
    }

    return CoachInsightModel.create(
      kind: CoachInsightKind.recommendation,
      category: CoachInsightCategory.openings,
      title: 'Stabilize the first phase',
      message: weakPhase == 'opening'
          ? 'Opening losses are your loudest pattern. Prioritize quick development, king safety, and avoiding early queen adventures.'
          : 'Your opening data is still forming. Choose one reliable setup and repeat it for a clearer progress signal.',
      actionLabel: 'Use a consistent setup',
      priority: weakPhase == 'opening' ? 90 : 68,
      confidence: _confidence(report.totalMatches),
      metricLabel: 'Opening samples',
      metricValue: '${report.openingWinRates.length}',
      isPositive: weakPhase != 'opening',
    );
  }

  CoachInsightModel _pacingRecommendation(GameplayPatternReport report) {
    final enoughPaceData = report.fastMatches >= 2 && report.slowMatches >= 2;
    if (enoughPaceData && report.slowWinRate > report.fastWinRate + 0.15) {
      return CoachInsightModel.create(
        kind: CoachInsightKind.recommendation,
        category: CoachInsightCategory.pacing,
        title: 'Slow down critical moves',
        message:
            'Your results are stronger in slower games. Add a final blunder check before captures, checks, and queen moves.',
        actionLabel: 'Use a 10-second scan',
        priority: 92,
        confidence: _confidence(report.totalMatches),
        metricLabel: 'Slow-game edge',
        metricValue: '+${_percent(report.slowWinRate - report.fastWinRate)}',
        isPositive: false,
      );
    }

    return CoachInsightModel.create(
      kind: CoachInsightKind.recommendation,
      category: CoachInsightCategory.pacing,
      title: 'Keep tempo intentional',
      message:
          'Your current pace is balanced. Preserve it by spending extra time only when material or king safety changes.',
      actionLabel: 'Pause on forcing moves',
      priority: 62,
      confidence: _confidence(report.totalMatches),
      metricLabel: 'Avg move',
      metricValue: '${report.averageMoveSeconds.toStringAsFixed(1)}s',
    );
  }

  CoachInsightModel _defenseRecommendation(GameplayPatternReport report) {
    if (report.defensiveMatches >= 2 && report.defensiveWinRate >= 0.58) {
      return CoachInsightModel.create(
        kind: CoachInsightKind.recommendation,
        category: CoachInsightCategory.defense,
        title: 'Convert defensive structure',
        message:
            'You score well after early development and castling patterns. Practice turning that stable setup into active rook play.',
        actionLabel: 'Activate rooks earlier',
        priority: 76,
        confidence: _confidence(report.totalMatches),
        metricLabel: 'Defensive win rate',
        metricValue: _percent(report.defensiveWinRate),
      );
    }

    return CoachInsightModel.create(
      kind: CoachInsightKind.recommendation,
      category: CoachInsightCategory.defense,
      title: 'Make king safety automatic',
      message:
          'Your defensive setup is not yet a consistent strength. Aim to castle, connect rooks, and ask what your opponent threatens.',
      actionLabel: 'Castle before attacks',
      priority: 82,
      confidence: _confidence(report.totalMatches),
      metricLabel: 'Defensive games',
      metricValue: '${report.defensiveMatches}',
      isPositive: false,
    );
  }

  CoachInsightModel _aggressionRecommendation(GameplayPatternReport report) {
    if (report.aggressiveMatches >= 2 && report.aggressiveWinRate < 0.45) {
      return CoachInsightModel.create(
        kind: CoachInsightKind.recommendation,
        category: CoachInsightCategory.aggression,
        title: 'Attack after development',
        message:
            'Early aggression is costing points. Delay sacrifices and queen sorties until at least two minor pieces are active.',
        actionLabel: 'Develop before forcing play',
        priority: 94,
        confidence: _confidence(report.totalMatches),
        metricLabel: 'Aggressive win rate',
        metricValue: _percent(report.aggressiveWinRate),
        isPositive: false,
      );
    }

    return CoachInsightModel.create(
      kind: CoachInsightKind.recommendation,
      category: CoachInsightCategory.aggression,
      title: 'Keep pressure selective',
      message:
          'Your attacking games are not showing a major leak. Keep choosing forcing lines when your king is safe and pieces are coordinated.',
      actionLabel: 'Attack with support',
      priority: 64,
      confidence: _confidence(report.totalMatches),
      metricLabel: 'Attack samples',
      metricValue: '${report.aggressiveMatches}',
    );
  }

  CoachInsightModel _timeManagementRecommendation(
      GameplayPatternReport report) {
    if (report.averageMoveSeconds > 0 && report.averageMoveSeconds < 7) {
      return CoachInsightModel.create(
        kind: CoachInsightKind.recommendation,
        category: CoachInsightCategory.timeManagement,
        title: 'Add time to tactical positions',
        message:
            'Your average move is very quick. Spend more clock when pieces are hanging, kings are exposed, or pawns can promote.',
        actionLabel: 'Slow tactical moments',
        priority: 86,
        confidence: _confidence(report.totalMatches),
        metricLabel: 'Avg move',
        metricValue: '${report.averageMoveSeconds.toStringAsFixed(1)}s',
        isPositive: false,
      );
    }

    return CoachInsightModel.create(
      kind: CoachInsightKind.recommendation,
      category: CoachInsightCategory.timeManagement,
      title: 'Protect endgame clock',
      message:
          'Your pace gives you room to calculate. Reserve a little extra time for pawn races and king activity after move 30.',
      actionLabel: 'Save clock for endings',
      priority: 70,
      confidence: _confidence(report.totalMatches),
      metricLabel: 'Avg duration',
      metricValue: '${report.averageDuration.inMinutes}m',
    );
  }

  double _confidence(int totalMatches) {
    return (0.55 + totalMatches * 0.035).clamp(0.6, 0.92).toDouble();
  }

  String _percent(double value) {
    return '${(value * 100).round()}%';
  }
}
