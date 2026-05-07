import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:en_passant/ai_coach/ai_coach_engine.dart';
import 'package:en_passant/models/analytics_model.dart';
import 'package:en_passant/models/coach_insight_model.dart';
import 'package:en_passant/models/match_model.dart';
import 'package:en_passant/models/puzzle_attempt_model.dart';
import 'package:en_passant/models/puzzle_progress_model.dart';
import 'package:en_passant/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> matchHistoryRef(String userId) {
    return _users.doc(userId).collection('match_history');
  }

  DocumentReference<Map<String, dynamic>> analyticsSummaryRef(String userId) {
    return _users.doc(userId).collection('analytics').doc('summary');
  }

  CollectionReference<Map<String, dynamic>> coachInsightsRef(String userId) {
    return _users.doc(userId).collection('coach_insights');
  }

  DocumentReference<Map<String, dynamic>> coachSummaryRef(String userId) {
    return _users.doc(userId).collection('ai_coach').doc('summary');
  }

  CollectionReference<Map<String, dynamic>> puzzleAttemptsRef(String userId) {
    return _users.doc(userId).collection('puzzle_attempts');
  }

  DocumentReference<Map<String, dynamic>> puzzleProgressRef(String userId) {
    return _users.doc(userId).collection('puzzles').doc('progress');
  }

  Future<void> createOrUpdateUser(UserModel user) async {
    await _users.doc(user.uid).set({
      ...user.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    final data = snapshot.data();
    if (data == null) return null;
    return UserModel.fromMap(data);
  }

  Future<MatchModel> saveMatch(MatchModel match) async {
    final doc = await matchHistoryRef(match.userId).add(match.toFirestore());
    return match.copyWith(id: doc.id);
  }

  Future<List<MatchModel>> getMatchHistory(String userId) async {
    final snapshot = await matchHistoryRef(userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.map(MatchModel.fromFirestore).toList();
  }

  Stream<List<MatchModel>> watchMatchHistory(String userId) {
    return matchHistoryRef(userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map(
            (snapshot) => snapshot.docs.map(MatchModel.fromFirestore).toList());
  }

  Future<void> saveAnalyticsSummary({
    required String userId,
    required AnalyticsModel analytics,
  }) async {
    await analyticsSummaryRef(userId).set({
      'totalMatches': analytics.totalMatches,
      'wins': analytics.wins,
      'losses': analytics.losses,
      'draws': analytics.draws,
      'currentStreak': analytics.currentStreak,
      'averageDurationSeconds': analytics.averageDuration.inSeconds,
      'winRate': analytics.winRate,
      'insights': analytics.insights,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<CoachInsightModel>> getCoachInsights(String userId) async {
    final snapshot = await coachInsightsRef(userId)
        .orderBy('priority', descending: true)
        .limit(30)
        .get();

    return snapshot.docs.map(CoachInsightModel.fromFirestore).toList();
  }

  Stream<List<CoachInsightModel>> watchCoachInsights(String userId) {
    return coachInsightsRef(userId)
        .orderBy('priority', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(CoachInsightModel.fromFirestore).toList());
  }

  Future<void> saveCoachReport({
    required String userId,
    required AiCoachReport report,
  }) async {
    final existingInsights = await coachInsightsRef(userId).get();
    final batch = _firestore.batch();

    batch.set(
      coachSummaryRef(userId),
      {
        'headline': report.summary.headline,
        'detail': report.summary.detail,
        'winRateLabel': report.summary.winRateLabel,
        'trendLabel': report.summary.trendLabel,
        'paceLabel': report.summary.paceLabel,
        'focusLabel': report.summary.focusLabel,
        'totalMatches': report.patterns.totalMatches,
        'winRate': report.patterns.winRate,
        'recentWinRate': report.patterns.recentWinRate,
        'averageMoveSeconds': report.patterns.averageMoveSeconds,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    for (final doc in existingInsights.docs) {
      batch.delete(doc.reference);
    }
    for (final insight in report.allInsights) {
      batch.set(
        coachInsightsRef(userId).doc(insight.id),
        {
          ...insight.toFirestore(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  // Puzzle-related methods

  Future<PuzzleAttemptModel> savePuzzleAttempt(
    String userId,
    PuzzleAttemptModel attempt,
  ) async {
    final doc = await puzzleAttemptsRef(userId).add(attempt.toFirestore());
    return attempt.copyWith(id: doc.id);
  }

  Future<void> savePuzzleProgress({
    required String userId,
    required PuzzleProgressModel progress,
  }) async {
    await puzzleProgressRef(userId).set(
      progress.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<PuzzleProgressModel?> getPuzzleProgress(String userId) async {
    final snapshot = await puzzleProgressRef(userId).get();
    final data = snapshot.data();
    if (data == null) return null;
    return PuzzleProgressModel.fromMap({...data, 'id': snapshot.id});
  }

  Stream<PuzzleProgressModel?> watchPuzzleProgress(String userId) {
    return puzzleProgressRef(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return PuzzleProgressModel.fromMap({...data, 'id': snapshot.id});
    });
  }

  Future<List<PuzzleAttemptModel>> getPuzzleAttempts(String userId) async {
    final snapshot = await puzzleAttemptsRef(userId)
        .orderBy('attemptedAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.map(PuzzleAttemptModel.fromFirestore).toList();
  }

  Stream<List<PuzzleAttemptModel>> watchPuzzleAttempts(String userId) {
    return puzzleAttemptsRef(userId)
        .orderBy('attemptedAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(PuzzleAttemptModel.fromFirestore).toList());
  }

  Future<PuzzleAttemptModel?> getLastPuzzleAttempt(String userId) async {
    final snapshot = await puzzleAttemptsRef(userId)
        .orderBy('attemptedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return PuzzleAttemptModel.fromFirestore(snapshot.docs.first);
  }

  Future<bool> hasCompletedDailyPuzzleToday(String userId) async {
    final progress = await getPuzzleProgress(userId);
    if (progress == null) return false;
    
    if (progress.dailyPuzzleCompletedDate == null) return false;
    
    final today = DateTime.now();
    final completed = progress.dailyPuzzleCompletedDate!;
    
    return today.year == completed.year &&
        today.month == completed.month &&
        today.day == completed.day;
  }
}
