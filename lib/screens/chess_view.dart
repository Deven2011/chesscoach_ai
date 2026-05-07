import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/logic/chess_game.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/app_themes.dart' as board_themes;
import 'package:en_passant/providers/auth_provider.dart' as auth;
import 'package:en_passant/providers/match_history_provider.dart';
import 'package:en_passant/widgets/chess_view/chess_board_widget.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls/game_status.dart';
import 'package:en_passant/widgets/chess_view/promotion_dialog.dart';
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
        _appModel.restoreGameState().then((_) => _initFlameGame());
      } else {
        _appModel.newGame(notify: false);
        _initFlameGame();
      }
    });
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
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ChessBoardWidget(appModel, chessGame!),
                        ),
                      ),
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
