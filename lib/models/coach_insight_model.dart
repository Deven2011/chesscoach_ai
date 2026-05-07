import 'package:cloud_firestore/cloud_firestore.dart';

enum CoachInsightKind {
  summary,
  insight,
  recommendation,
  tendency,
  strength,
  weakness,
  trend,
}

enum CoachInsightCategory {
  performance,
  openings,
  pacing,
  defense,
  aggression,
  timeManagement,
  endgame,
  difficulty,
}

class CoachInsightModel {
  final String id;
  final CoachInsightKind kind;
  final CoachInsightCategory category;
  final String title;
  final String message;
  final String actionLabel;
  final int priority;
  final double confidence;
  final String metricLabel;
  final String metricValue;
  final bool isPositive;
  final DateTime generatedAt;

  const CoachInsightModel({
    required this.id,
    required this.kind,
    required this.category,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.priority,
    required this.confidence,
    required this.metricLabel,
    required this.metricValue,
    required this.isPositive,
    required this.generatedAt,
  });

  factory CoachInsightModel.create({
    required CoachInsightKind kind,
    required CoachInsightCategory category,
    required String title,
    required String message,
    String actionLabel = '',
    int priority = 50,
    double confidence = 0.75,
    String metricLabel = '',
    String metricValue = '',
    bool isPositive = true,
    DateTime? generatedAt,
  }) {
    return CoachInsightModel(
      id: stableId(kind: kind, category: category, title: title),
      kind: kind,
      category: category,
      title: title,
      message: message,
      actionLabel: actionLabel,
      priority: priority.clamp(0, 100).toInt(),
      confidence: confidence.clamp(0, 1).toDouble(),
      metricLabel: metricLabel,
      metricValue: metricValue,
      isPositive: isPositive,
      generatedAt: generatedAt ?? DateTime.now(),
    );
  }

  factory CoachInsightModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return CoachInsightModel(
      id: snapshot.id,
      kind: _parseKind(data['kind'] as String?),
      category: _parseCategory(data['category'] as String?),
      title: data['title'] as String? ?? 'Coach insight',
      message: data['message'] as String? ?? '',
      actionLabel: data['actionLabel'] as String? ?? '',
      priority: data['priority'] as int? ?? 50,
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.75,
      metricLabel: data['metricLabel'] as String? ?? '',
      metricValue: data['metricValue'] as String? ?? '',
      isPositive: data['isPositive'] as bool? ?? true,
      generatedAt:
          (data['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'kind': kind.name,
      'category': category.name,
      'title': title,
      'message': message,
      'actionLabel': actionLabel,
      'priority': priority,
      'confidence': confidence,
      'metricLabel': metricLabel,
      'metricValue': metricValue,
      'isPositive': isPositive,
      'generatedAt': Timestamp.fromDate(generatedAt),
    };
  }

  static String stableId({
    required CoachInsightKind kind,
    required CoachInsightCategory category,
    required String title,
  }) {
    final normalized = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return '${kind.name}-${category.name}-$normalized';
  }

  static CoachInsightKind _parseKind(String? value) {
    return CoachInsightKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => CoachInsightKind.insight,
    );
  }

  static CoachInsightCategory _parseCategory(String? value) {
    return CoachInsightCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => CoachInsightCategory.performance,
    );
  }
}
