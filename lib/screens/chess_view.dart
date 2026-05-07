import 'dart:ui' as ui;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/logic/chess_game.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/providers/auth_provider.dart' as auth;
import 'package:en_passant/providers/match_history_provider.dart';
import 'package:en_passant/providers/realtime_coach_provider.dart';
import 'package:en_passant/providers/replay_provider.dart';
import 'package:en_passant/screens/replay/replay_screen.dart';
import 'package:en_passant/widgets/chess_view/chess_board_widget.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls/game_status.dart';
import 'package:en_passant/widgets/chess_view/promotion_dialog.dart';
import 'package:en_passant/widgets/coach/coach_sidebar.dart';
import 'package:en_passant/widgets/coach/move_feedback_card.dart';
import 'package:en_passant/widgets/coach/move_quality_badge.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class ChessView extends StatefulWidget {
  final AppModel appModel;
  final bool isResuming;

  const ChessView(this.appModel, {super.key, this.isResuming = false});

  @override
  State<ChessView> createState() => _ChessViewState();
}

class _ChessViewState extends State<ChessView> with WidgetsBindingObserver {
  late AppModel _appModel;
  ChessGame? chessGame;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _appModel = widget.appModel;
    WidgetsBinding.instance.addObserver(this);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isResuming) {
        _appModel.restoreGameState().then((_) {
          _wireRealtimeCoach();
          _initFlameGame();
        });
      } else {
        _appModel.newGame(notify: false);
        _wireRealtimeCoach();
        _initFlameGame();
      }
    });
  }

  void _wireRealtimeCoach() {
    if (!mounted) return;
    final coach = context.read<RealtimeCoachProvider>();
    coach.startGame(enabled: _appModel.coachModeEnabled);
    _appModel.onRealtimeCoachMove = coach.analyzeMove;
  }

  void _initFlameGame() {
    if (_appModel.gameController != null) {
      if (mounted) {
        setState(() {
          chessGame = ChessGame(_appModel.gameController!, _appModel);
        });
      }
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _appModel.update();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appModel.onRealtimeCoachMove = null;
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_appModel.gameOver) {
        _appModel.saveGameState();
        _appModel.timerService.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_appModel.gameOver) {
        _appModel.timerService.resume();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, appModel, child) {
        if (appModel.gameController == null || chessGame == null) {
          return const AppScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (appModel.promotionRequested) {
          appModel.promotionRequested = false;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _showPromotionDialog(appModel));
        }

        if (appModel.gameOver && appModel.userWon) {
          _confettiController.play();
        } else {
          _confettiController.stop();
        }

        if (appModel.gameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.read<RealtimeCoachProvider>().completeGameReview();
            final userId = context.read<auth.AuthProvider>().user?.uid;
            if (userId == null) return;
            context.read<MatchHistoryProvider>().saveCompletedMatch(
                  userId: userId,
                  appModel: appModel,
                );
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (appModel.gameOver) {
              appModel.exitChessView();
              Navigator.of(context).pop();
            } else {
              _showExitDialog(context, appModel);
            }
          },
          child: AppScaffold(
            padding: EdgeInsets.zero,
            appBar: AppScaffold.transparentAppBar(
              title: 'CHESS COACH',
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  if (appModel.gameOver) {
                    appModel.exitChessView();
                    Navigator.of(context).pop();
                  } else {
                    _showExitDialog(context, appModel);
                  }
                },
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    const GameStatus(),
                    Expanded(child: _CoachBoardStage(appModel, chessGame!)),
                    if (appModel.playingAgainstCoach)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                        child: _CoachDock(
                          isGameOver: appModel.gameOver,
                          onOpenPanel: () => _showCoachPanel(context, appModel),
                        ),
                      ),
                    if (appModel.gameOver)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: _PostGameReviewButton(appModel: appModel),
                      ),
                    GameInfoAndControls(appModel),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: [
                      appModel.theme.lightTile,
                      appModel.theme.darkTile,
                      appModel.theme.moveHint,
                      appModel.theme.latestMove,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCoachPanel(BuildContext context, AppModel appModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: appModel.gameOver ? 0.58 : 0.46,
          minChildSize: 0.26,
          maxChildSize: 0.86,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  MediaQuery.of(context).padding.bottom + 14,
                ),
                child: CoachSidebar(isGameOver: appModel.gameOver),
              ),
            );
          },
        );
      },
    );
  }

  void _showPromotionDialog(AppModel appModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PromotionDialog(appModel);
      },
    );
  }

  void _showExitDialog(BuildContext context, AppModel appModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Exit Game?', style: AppTextStyles.headline3(context)),
        content: Text('Do you want to save your progress?',
            style: AppTextStyles.body1(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              appModel.exitChessView();
              Navigator.of(context).pop();
            },
            child: const Text('EXIT WITHOUT SAVING'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              appModel.saveAndExitChessView();
              Navigator.of(context).pop();
            },
            child: const Text('SAVE & EXIT'),
          ),
        ],
      ),
    );
  }
}

class _CoachBoardStage extends StatelessWidget {
  final AppModel appModel;
  final ChessGame chessGame;

  const _CoachBoardStage(this.appModel, this.chessGame);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showCoach = appModel.playingAgainstCoach;
        final evalStripHeight = showCoach ? 36.0 : 0.0;
        final evalGap = showCoach ? 8.0 : 0.0;
        final availableWidth = constraints.maxWidth - 24;
        final availableHeight =
            constraints.maxHeight - evalStripHeight - evalGap - 16;
        var boardSize =
            availableWidth < availableHeight ? availableWidth : availableHeight;
        if (boardSize < 0) boardSize = 0;

        return Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize + evalStripHeight + evalGap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCoach) ...[
                  SizedBox(
                    width: boardSize,
                    height: evalStripHeight,
                    child: const _CoachEvaluationOverlay(),
                  ),
                  SizedBox(height: evalGap),
                ],
                SizedBox(
                  width: boardSize,
                  height: boardSize,
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      ChessBoardWidget(appModel, chessGame),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostGameReviewButton extends StatelessWidget {
  final AppModel appModel;

  const _PostGameReviewButton({required this.appModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {
          final reviews = context.read<RealtimeCoachProvider>().reviews;
          context.read<ReplayProvider>().loadFromGame(
                appModel: appModel,
                reviews: reviews,
              );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReplayScreen()),
          );
        },
        icon: const Icon(Icons.insights_rounded),
        label: Text(
          'REVIEW & REPLAY GAME',
          style: AppTextStyles.button(context).copyWith(
            color: AppColors.onSecondary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CoachEvaluationOverlay extends StatelessWidget {
  const _CoachEvaluationOverlay();

  @override
  Widget build(BuildContext context) {
    return Consumer<RealtimeCoachProvider>(
      builder: (context, coach, child) {
        return _CoachEvaluationStrip(
          value: coach.normalizedEvaluation,
          centipawnEval: coach.latestReview?.afterEval,
          isAnalyzing: coach.isAnalyzing,
        );
      },
    );
  }
}

class _CoachMoveToast extends StatelessWidget {
  const _CoachMoveToast();

  @override
  Widget build(BuildContext context) {
    return Consumer<RealtimeCoachProvider>(
      builder: (context, coach, child) {
        final review = coach.overlayReview;
        if (review == null) return const SizedBox.shrink();

        return Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Center(
            child: MoveFeedbackCard(
              review: review,
              overlay: true,
            ),
          ),
        );
      },
    );
  }
}

class _CoachEvaluationStrip extends StatelessWidget {
  final double value;
  final int? centipawnEval;
  final bool isAnalyzing;

  const _CoachEvaluationStrip({
    required this.value,
    required this.centipawnEval,
    required this.isAnalyzing,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.05, 0.95).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.26),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                _label(centipawnEval),
                style: AppTextStyles.monoCode(context).copyWith(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            height: 8,
                            color: Colors.white.withValues(alpha: 0.11),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            width: constraints.maxWidth * clamped,
                            height: 8,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (isAnalyzing) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _label(int? eval) {
    if (eval == null) return '0.0';
    final pawns = eval / 100;
    if (pawns > 0) return '+${pawns.toStringAsFixed(1)}';
    return pawns.toStringAsFixed(1);
  }
}

class _CoachDock extends StatelessWidget {
  final bool isGameOver;
  final VoidCallback onOpenPanel;

  const _CoachDock({
    required this.isGameOver,
    required this.onOpenPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RealtimeCoachProvider>(
      builder: (context, coach, child) {
        final latestReview = coach.latestReview;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenPanel,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 58),
                  padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.9),
                              AppColors.secondary.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    isGameOver
                                        ? 'Post-game coach review'
                                        : latestReview?.title ?? 'Live coach',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        AppTextStyles.body2(context).copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                if (latestReview != null) ...[
                                  const SizedBox(width: 7),
                                  MoveQualityBadge(
                                    quality: latestReview.quality,
                                    compact: true,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _subtitle(coach),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption(context).copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MiniStat(label: 'Acc', value: '${coach.accuracy}%'),
                      const SizedBox(width: 7),
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: AppColors.secondary.withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _subtitle(RealtimeCoachProvider coach) {
    if (coach.errorMessage != null) return coach.errorMessage!;
    if (coach.isAnalyzing) return 'Analyzing current position...';
    if (coach.latestReview != null) {
      return 'Tap for insight, move history, and evaluation details';
    }
    return 'Make a move to receive compact live feedback';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.monoCode(context).copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
