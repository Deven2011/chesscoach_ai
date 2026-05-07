import 'package:en_passant/ai_coach/gameplay_pattern_analyzer.dart';
import 'package:en_passant/ai_coach/recommendation_engine.dart';
import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/models/coach_insight_model.dart';
import 'package:en_passant/models/match_model.dart';

class AiCoachEngine {
  final GameplayPatternAnalyzer _patternAnalyzer;
  final RecommendationEngine _recommendationEngine;

  const AiCoachEngine({
    GameplayPatternAnalyzer? patternAnalyzer,
    RecommendationEngine? recommendationEngine,
  })  : _patternAnalyzer = patternAnalyzer ?? const _DefaultPatternAnalyzer(),
        _recommendationEngine =
            recommendationEngine ?? const _DefaultRecommendationEngine();

  AiCoachReport buildReport(List<MatchModel> matches) {
    final patterns = _patternAnalyzer.analyze(matches);
    final insights = _buildInsights(patterns);
    final recommendations = _recommendationEngine.generate(patterns);
    final strengths = _buildStrengths(patterns);
    final weaknesses = _buildWeaknesses(patterns);
    final tendencies = _buildTendencies(patterns);

    return AiCoachReport(
      generatedAt: DateTime.now(),
      patterns: patterns,
      summary: _summary(patterns),
      insights: _prioritize(insights),
      recommendations: recommendations,
      strengths: _prioritize(strengths),
      weaknesses: _prioritize(weaknesses),
      tendencies: _prioritize(tendencies),
    );
  }

  CoachPerformanceSummary _summary(GameplayPatternReport report) {
    if (report.totalMatches == 0) {
      return const CoachPerformanceSummary(
        headline: 'Ready to learn your style',
        detail:
            'Complete a match to unlock personalized coaching, trend analysis, and improvement plans.',
        winRateLabel: '0%',
        trendLabel: 'No games yet',
        paceLabel: 'No pace data',
        focusLabel: 'First match',
      );
    }

    final trendLabel = report.previousWinRate == 0
        ? 'Building baseline'
        : report.trendDelta >= 0
            ? '+${(report.trendDelta * 100).round()} pts recent'
            : '${(report.trendDelta * 100).round()} pts recent';
    final focus = report.weakestPhase.isEmpty
        ? 'Balanced review'
        : '${_capitalize(report.weakestPhase)} training';

    return CoachPerformanceSummary(
      headline: report.winRate >= 0.55
          ? 'Your chess profile is trending strong'
          : 'Your coach has a clear improvement path',
      detail:
          '${report.totalMatches} games analyzed across color, pace, phase, opening family, and AI difficulty.',
      winRateLabel: _percent(report.winRate),
      trendLabel: trendLabel,
      paceLabel: report.averageMoveSeconds == 0
          ? '${report.averageDuration.inMinutes}m games'
          : '${report.averageMoveSeconds.toStringAsFixed(1)}s per move',
      focusLabel: focus,
    );
  }

  List<CoachInsightModel> _buildInsights(GameplayPatternReport report) {
    if (report.totalMatches == 0) {
      return [
        CoachInsightModel.create(
          kind: CoachInsightKind.insight,
          category: CoachInsightCategory.performance,
          title: 'No match history yet',
          message:
              'ChessCoach AI will start interpreting your strengths, tendencies, and training priorities after your first completed game.',
          actionLabel: 'Play a match',
          priority: 95,
          confidence: 0.7,
          metricLabel: 'Tracked games',
          metricValue: '0',
        ),
      ];
    }

    final insights = <CoachInsightModel>[];
    final bestColor = report.bestColor;
    if (bestColor.isNotEmpty && report.colorWinRates.length > 1) {
      insights.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.insight,
          category: CoachInsightCategory.performance,
          title: '$bestColor pieces are stronger',
          message: 'You perform better with ${bestColor.toLowerCase()} pieces.',
          actionLabel: 'Compare first 12 moves',
          priority: 82,
          confidence: _confidence(report.totalMatches),
          metricLabel: '$bestColor win rate',
          metricValue: _percent(report.colorWinRates[bestColor]!),
        ),
      );
    }

    if (report.weakestPhase.isNotEmpty &&
        (report.lossPhaseCounts[report.weakestPhase] ?? 0) >= 2) {
      final moveHint = report.weakestPhase == 'endgame'
          ? ' after move 30'
          : report.weakestPhase == 'opening'
              ? ' before move 10'
              : ' during the middlegame';
      insights.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.insight,
          category: report.weakestPhase == 'endgame'
              ? CoachInsightCategory.endgame
              : CoachInsightCategory.performance,
          title: '${_capitalize(report.weakestPhase)} losses detected',
          message: 'You struggle in ${report.weakestPhase}s$moveHint.',
          actionLabel: 'Review recent losses',
          priority: 90,
          confidence: _confidence(report.totalMatches),
          metricLabel: 'Losses',
          metricValue: '${report.lossPhaseCounts[report.weakestPhase]}',
          isPositive: false,
        ),
      );
    }

    final difficultyTrend = report.improvingDifficulty;
    if (difficultyTrend != null) {
      insights.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.trend,
          category: CoachInsightCategory.difficulty,
          title: '${_capitalize(difficultyTrend.label)} AI progress',
          message:
              'Your win rate against ${difficultyTrend.label} AI improved by ${(difficultyTrend.delta * 100).round()}%.',
          actionLabel: 'Keep this level active',
          priority: 88,
          confidence: _confidence(report.totalMatches),
          metricLabel: 'Improvement',
          metricValue: '+${_percent(difficultyTrend.delta)}',
        ),
      );
    }

    if (report.aggressiveMatches >= 2 && report.aggressiveWinRate < 0.45) {
      insights.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.insight,
          category: CoachInsightCategory.aggression,
          title: 'Early attacks are risky',
          message: 'You tend to lose when playing too aggressively early.',
          actionLabel: 'Develop before attacks',
          priority: 94,
          confidence: _confidence(report.totalMatches),
          metricLabel: 'Aggressive win rate',
          metricValue: _percent(report.aggressiveWinRate),
          isPositive: false,
        ),
      );
    }

    if (report.fastMatches >= 2 &&
        report.slowMatches >= 2 &&
        report.slowWinRate > report.fastWinRate + 0.1) {
      insights.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.insight,
          category: CoachInsightCategory.pacing,
          title: 'Slower games improve results',
          message:
              'Your results improve in slower games, especially when you give tactics more time.',
          actionLabel: 'Pause on captures',
          priority: 86,
          confidence: _confidence(report.totalMatches),
          metricLabel: 'Slow-game edge',
          metricValue: '+${_percent(report.slowWinRate - report.fastWinRate)}',
        ),
      );
    }

    final bestOpening = report.bestOpening;
    if (bestOpening.isNotEmpty &&
        report.openingWinRates[bestOpening]! >= 0.58) {
      insights.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.insight,
          category: CoachInsightCategory.openings,
          title: '$bestOpening is working',
          message:
              'You have strong performance with ${bestOpening.toLowerCase()}s.',
          actionLabel: 'Build a second plan',
          priority: 80,
          confidence: _confidence(report.totalMatches),
          metricLabel: 'Opening win rate',
          metricValue: _percent(report.openingWinRates[bestOpening]!),
        ),
      );
    }

    if (insights.isEmpty) {
      insights.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.insight,
          category: CoachInsightCategory.performance,
          title: 'Baseline is forming',
          message:
              'Play a few more games to reveal stronger color, opening, pace, and phase patterns.',
          actionLabel: 'Complete 3 more games',
          priority: 70,
          confidence: 0.65,
          metricLabel: 'Tracked games',
          metricValue: '${report.totalMatches}',
        ),
      );
    }

    return insights;
  }

  List<CoachInsightModel> _buildStrengths(GameplayPatternReport report) {
    if (report.totalMatches == 0) return [];
    final strengths = <CoachInsightModel>[];

    if (report.currentWinStreak >= 2) {
      strengths.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.strength,
          category: CoachInsightCategory.performance,
          title: 'Momentum under control',
          message:
              'You are on a ${report.currentWinStreak}-game winning streak.',
          actionLabel: 'Raise difficulty when ready',
          priority: 78,
          metricLabel: 'Current streak',
          metricValue: '${report.currentWinStreak}',
        ),
      );
    }

    if (report.mostSuccessfulDifficulty > 0) {
      final label =
          AnalyticsModel.difficultyLabel(report.mostSuccessfulDifficulty);
      strengths.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.strength,
          category: CoachInsightCategory.difficulty,
          title: '${_capitalize(label)} AI comfort',
          message:
              'Your best AI difficulty performance is currently against $label opponents.',
          actionLabel: 'Use as training base',
          priority: 66,
          metricLabel: 'Win rate',
          metricValue: _percent(
              report.difficultyWinRates[report.mostSuccessfulDifficulty]!),
        ),
      );
    }

    if (report.defensiveMatches >= 2 && report.defensiveWinRate >= 0.55) {
      strengths.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.strength,
          category: CoachInsightCategory.defense,
          title: 'Solid setup games',
          message:
              'Your developed and castled positions are converting into better results.',
          actionLabel: 'Add active piece plans',
          priority: 74,
          metricLabel: 'Defensive win rate',
          metricValue: _percent(report.defensiveWinRate),
        ),
      );
    }

    return strengths;
  }

  List<CoachInsightModel> _buildWeaknesses(GameplayPatternReport report) {
    if (report.totalMatches == 0) return [];
    final weaknesses = <CoachInsightModel>[];

    if (report.currentLossStreak >= 2) {
      weaknesses.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.weakness,
          category: CoachInsightCategory.performance,
          title: 'Loss streak needs a reset',
          message:
              'You have dropped ${report.currentLossStreak} straight games. Lower the AI difficulty for one recovery game and focus on clean moves.',
          actionLabel: 'Play one reset game',
          priority: 93,
          metricLabel: 'Loss streak',
          metricValue: '${report.currentLossStreak}',
          isPositive: false,
        ),
      );
    }

    final weakPhase = report.weakestPhase;
    if (weakPhase.isNotEmpty && (report.lossPhaseCounts[weakPhase] ?? 0) >= 2) {
      weaknesses.add(
        CoachInsightModel.create(
          kind: CoachInsightKind.weakness,
          category: weakPhase == 'endgame'
              ? CoachInsightCategory.endgame
              : CoachInsightCategory.performance,
          title: '${_capitalize(weakPhase)} conversion gap',
          message:
              'Most of your losses cluster in the $weakPhase. That makes it the highest-value review area.',
          actionLabel: 'Replay losing phase',
          priority: 89,
          metricLabel: 'Phase losses',
          metricValue: '${report.lossPhaseCounts[weakPhase]}',
          isPositive: false,
        ),
      );
    }

    return weaknesses;
  }

  List<CoachInsightModel> _buildTendencies(GameplayPatternReport report) {
    if (report.totalMatches == 0) return [];
    return [
      CoachInsightModel.create(
        kind: CoachInsightKind.tendency,
        category: CoachInsightCategory.pacing,
        title: _paceTitle(report.averageMoveSeconds),
        message:
            'Your average move time is ${report.averageMoveSeconds.toStringAsFixed(1)} seconds across tracked games.',
        actionLabel: 'Tune clock habits',
        priority: 58,
        metricLabel: 'Avg move',
        metricValue: '${report.averageMoveSeconds.toStringAsFixed(1)}s',
      ),
      CoachInsightModel.create(
        kind: CoachInsightKind.tendency,
        category: CoachInsightCategory.aggression,
        title: report.aggressiveMatches >= report.defensiveMatches
            ? 'Aggressive early posture'
            : 'Defensive early posture',
        message:
            '${report.aggressiveMatches} aggressive openings and ${report.defensiveMatches} defensive setups were detected.',
        actionLabel: 'Balance risk and safety',
        priority: 56,
        metricLabel: 'Detected style',
        metricValue: report.aggressiveMatches >= report.defensiveMatches
            ? 'Aggressive'
            : 'Defensive',
      ),
    ];
  }

  List<CoachInsightModel> _prioritize(List<CoachInsightModel> insights) {
    final sorted = [...insights]
      ..sort((a, b) => b.priority.compareTo(a.priority));
    return sorted;
  }

  double _confidence(int totalMatches) {
    return (0.55 + totalMatches * 0.035).clamp(0.6, 0.92).toDouble();
  }

  String _percent(double value) {
    return '${(value * 100).round()}%';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _paceTitle(double averageMoveSeconds) {
    if (averageMoveSeconds == 0) return 'Pace data pending';
    if (averageMoveSeconds < 7) return 'Fast tactical tempo';
    if (averageMoveSeconds > 14) return 'Deliberate calculation tempo';
    return 'Balanced calculation tempo';
  }
}

class AiCoachReport {
  final DateTime generatedAt;
  final GameplayPatternReport patterns;
  final CoachPerformanceSummary summary;
  final List<CoachInsightModel> insights;
  final List<CoachInsightModel> recommendations;
  final List<CoachInsightModel> strengths;
  final List<CoachInsightModel> weaknesses;
  final List<CoachInsightModel> tendencies;

  const AiCoachReport({
    required this.generatedAt,
    required this.patterns,
    required this.summary,
    required this.insights,
    required this.recommendations,
    required this.strengths,
    required this.weaknesses,
    required this.tendencies,
  });

  factory AiCoachReport.empty() {
    return AiCoachEngine().buildReport(const []);
  }

  List<CoachInsightModel> get allInsights => [
        ...insights,
        ...recommendations,
        ...strengths,
        ...weaknesses,
        ...tendencies,
      ];
}

class CoachPerformanceSummary {
  final String headline;
  final String detail;
  final String winRateLabel;
  final String trendLabel;
  final String paceLabel;
  final String focusLabel;

  const CoachPerformanceSummary({
    required this.headline,
    required this.detail,
    required this.winRateLabel,
    required this.trendLabel,
    required this.paceLabel,
    required this.focusLabel,
  });
}

class _DefaultPatternAnalyzer extends GameplayPatternAnalyzer {
  const _DefaultPatternAnalyzer();
}

class _DefaultRecommendationEngine extends RecommendationEngine {
  const _DefaultRecommendationEngine();
}
