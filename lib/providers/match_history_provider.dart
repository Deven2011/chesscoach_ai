import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:en_passant/firebase/firestore_service.dart';
import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/match_model.dart';
import 'package:en_passant/models/player.dart';
import 'package:en_passant/models/sync_state_model.dart';
import 'package:en_passant/services/offline_cache_service.dart';
import 'package:en_passant/services/sync_service.dart';

class MatchHistoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final OfflineCacheService _cacheService;
  final SyncService _syncService;

  StreamSubscription<List<MatchModel>>? _subscription;
  List<MatchModel> _matches = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _activeUserId;
  final Set<String> _savedGameFingerprints = {};

  MatchHistoryProvider({
    FirestoreService? firestoreService,
    OfflineCacheService? cacheService,
    SyncService? syncService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _cacheService = cacheService ?? OfflineCacheService(),
        _syncService = syncService ?? SyncService();

  List<MatchModel> get matches => List.unmodifiable(_matches);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  void bindUser(String? userId) {
    if (_activeUserId == userId) return;
    _activeUserId = userId;
    _subscription?.cancel();
    _matches = [];
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;

    if (userId == null) {
      scheduleMicrotask(notifyListeners);
      return;
    }

    _isLoading = true;
    scheduleMicrotask(notifyListeners);
    unawaited(_loadCachedMatches(userId));
    _subscription = _firestoreService.watchMatchHistory(userId).listen(
      (matches) {
        _matches = _dedupeMatches(matches);
        _isLoading = false;
        _errorMessage = null;
        unawaited(_cacheService.saveMatches(userId, _matches));
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = _matches.isEmpty
            ? 'Could not load match history.'
            : 'Showing cached match history.';
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    final userId = _activeUserId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      _matches =
          _dedupeMatches(await _firestoreService.getMatchHistory(userId));
      _errorMessage = null;
      await _cacheService.saveMatches(userId, _matches);
    } on Object {
      final cached = await _cacheService.getMatches(userId);
      if (cached.isNotEmpty) {
        _matches = _dedupeMatches(cached);
        _errorMessage = 'Showing cached match history.';
      } else {
        _errorMessage = 'Could not refresh match history.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCompletedMatch({
    required String userId,
    required AppModel appModel,
  }) async {
    if (!appModel.gameOver || _isSaving) return;

    final fingerprint = _fingerprint(userId, appModel);
    if (_savedGameFingerprints.contains(fingerprint)) return;
    _savedGameFingerprints.add(fingerprint);
    _isSaving = true;
    notifyListeners();

    try {
      final match = _matchFromAppModel(userId: userId, appModel: appModel);
      _matches = _dedupeMatches([match, ..._matches]);
      await _cacheService.saveMatches(userId, _matches);
      await _firestoreService.saveMatch(match);
      _errorMessage = null;
    } on Object {
      final match = _matchFromAppModel(userId: userId, appModel: appModel);
      await _syncService.enqueue(
        SyncActionModel.create(
          type: SyncActionType.saveMatch,
          userId: userId,
          payload: match.toMap(),
        ),
      );
      _errorMessage = 'Match saved locally. It will sync automatically.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _loadCachedMatches(String userId) async {
    final cached = await _cacheService.getMatches(userId);
    if (cached.isEmpty || _matches.isNotEmpty) return;
    _matches = _dedupeMatches(cached);
    _isLoading = false;
    _errorMessage = 'Showing cached match history.';
    notifyListeners();
  }

  String _fingerprint(String userId, AppModel appModel) {
    return [
      userId,
      appModel.playerCount,
      appModel.aiDifficulty,
      appModel.playerSide.index,
      appModel.timeLimit,
      appModel.moveMetaList.length,
      appModel.gameStartedAt?.millisecondsSinceEpoch ?? 0,
      appModel.stalemate,
      appModel.userWon,
    ].join(':');
  }

  MatchModel _matchFromAppModel({
    required String userId,
    required AppModel appModel,
  }) {
    final result = appModel.stalemate
        ? MatchResult.draw
        : appModel.userWon
            ? MatchResult.win
            : MatchResult.loss;
    final winner = appModel.stalemate
        ? 'Draw'
        : appModel.turn == Player.player1
            ? 'Black'
            : 'White';
    final profile = _gameplayProfile(appModel);

    return MatchModel.completed(
      userId: userId,
      winner: winner,
      gameMode: appModel.playingAgainstCoach
          ? 'Play Against Coach'
          : appModel.playingWithAI
              ? 'Play vs AI'
              : '2 Player Local',
      aiDifficulty: appModel.playingWithAI ? appModel.aiDifficulty : 0,
      duration: appModel.currentGameDuration,
      moveCount: appModel.moveMetaList.length,
      playerColor: _playerColor(appModel.playerSide),
      result: result,
      openingFamily: profile.openingFamily,
      lossPhase: result == MatchResult.loss ? profile.lossPhase : '',
      aggressionScore: profile.aggressionScore,
      defenseScore: profile.defenseScore,
      averageMoveSeconds: profile.averageMoveSeconds,
      moveHistory: _moveHistory(appModel),
    );
  }

  List<String> _moveHistory(AppModel appModel) {
    final history = <String>[];
    for (final meta in appModel.moveMetaList) {
      final move = meta.move;
      if (move == null) continue;
      history.add('${move.from}-${move.to}-${move.promotionType.index}');
    }
    return history;
  }

  _GameplayProfile _gameplayProfile(AppModel appModel) {
    final userMoves = appModel.moveMetaList
        .where((meta) => meta.player == appModel.playerSide)
        .toList();
    final earlyUserMoves = userMoves.take(8).toList();
    final earlyAllMoves = appModel.moveMetaList.take(16).toList();

    final captures = earlyUserMoves.where((meta) => meta.took).length;
    final checks = earlyUserMoves.where((meta) => meta.isCheck).length;
    final queenMoves = earlyUserMoves
        .where((meta) => meta.type == ChessPieceType.queen)
        .length;
    final knightMoves = earlyUserMoves
        .where((meta) => meta.type == ChessPieceType.knight)
        .length;
    final bishopMoves = earlyUserMoves
        .where((meta) => meta.type == ChessPieceType.bishop)
        .length;
    final pawnMoves =
        earlyUserMoves.where((meta) => meta.type == ChessPieceType.pawn).length;
    final castles = earlyAllMoves
        .where((meta) =>
            meta.player == appModel.playerSide &&
            (meta.kingCastle || meta.queenCastle))
        .length;

    final aggressiveEvents = captures + checks + queenMoves;
    final developmentEvents = knightMoves + bishopMoves + castles;
    final aggressionScore = earlyUserMoves.isEmpty
        ? 0.0
        : (aggressiveEvents / earlyUserMoves.length).clamp(0.0, 1.0).toDouble();
    final defenseScore = earlyUserMoves.isEmpty
        ? 0.0
        : ((developmentEvents + castles) / earlyUserMoves.length)
            .clamp(0.0, 1.0)
            .toDouble();

    final openingFamily = _openingFamily(
      knightMoves: knightMoves,
      bishopMoves: bishopMoves,
      pawnMoves: pawnMoves,
      queenMoves: queenMoves,
      castles: castles,
      aggressionScore: aggressionScore,
    );

    return _GameplayProfile(
      openingFamily: openingFamily,
      lossPhase: _lossPhase(appModel.moveMetaList.length),
      aggressionScore: aggressionScore,
      defenseScore: defenseScore,
      averageMoveSeconds: appModel.moveMetaList.isEmpty
          ? 0.0
          : appModel.currentGameDuration.inSeconds /
              appModel.moveMetaList.length,
    );
  }

  String _openingFamily({
    required int knightMoves,
    required int bishopMoves,
    required int pawnMoves,
    required int queenMoves,
    required int castles,
    required double aggressionScore,
  }) {
    if (knightMoves >= 2) return 'Knight-centered opening';
    if (castles > 0 && bishopMoves >= 1) return 'Castled development';
    if (queenMoves > 0 || aggressionScore >= 0.45) {
      return 'Early attacking opening';
    }
    if (pawnMoves >= 5) return 'Pawn-structure opening';
    if (bishopMoves + knightMoves >= 3) return 'Classical development';
    return 'Balanced opening';
  }

  String _lossPhase(int moveCount) {
    if (moveCount < 20) return 'opening';
    if (moveCount <= 60) return 'middlegame';
    return 'endgame';
  }

  String _playerColor(Player player) {
    switch (player) {
      case Player.player1:
        return 'White';
      case Player.player2:
        return 'Black';
      case Player.random:
        return 'Random';
    }
  }

  List<MatchModel> _dedupeMatches(List<MatchModel> matches) {
    final seen = <String>{};
    final unique = <MatchModel>[];
    for (final match in matches) {
      final key = _matchKey(match);
      if (seen.add(key)) {
        unique.add(match);
      }
    }
    return unique;
  }

  String _matchKey(MatchModel match) {
    return [
      match.userId,
      match.result.name,
      match.winner,
      match.moveCount,
      match.duration.inSeconds,
      match.gameMode,
      match.aiDifficulty,
      match.playerColor,
    ].join(':');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class _GameplayProfile {
  final String openingFamily;
  final String lossPhase;
  final double aggressionScore;
  final double defenseScore;
  final double averageMoveSeconds;

  const _GameplayProfile({
    required this.openingFamily,
    required this.lossPhase,
    required this.aggressionScore,
    required this.defenseScore,
    required this.averageMoveSeconds,
  });
}
