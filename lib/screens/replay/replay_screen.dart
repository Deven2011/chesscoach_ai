import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/logic/shared_functions.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/player.dart';
import 'package:en_passant/providers/replay_provider.dart';
import 'package:en_passant/screens/replay/game_review_screen.dart';
import 'package:en_passant/widgets/replay/critical_moment_card.dart';
import 'package:en_passant/widgets/replay/evaluation_graph.dart';
import 'package:en_passant/widgets/replay/move_timeline.dart';
import 'package:en_passant/widgets/replay/replay_controls.dart';
import 'package:en_passant/widgets/replay/review_summary_card.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';

class ReplayScreen extends StatelessWidget {
  const ReplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReplayProvider>(
      builder: (context, replay, child) {
        final state = replay.state;
        return AppScaffold(
          padding: EdgeInsets.zero,
          appBar: AppScaffold.transparentAppBar(
            title: 'GAME REPLAY',
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                tooltip: 'Review',
                icon: const Icon(Icons.analytics_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GameReviewScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null
                  ? _ReplayEmptyState(message: state.errorMessage!)
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: _ReplayBoardShell(),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: ReplayControls(),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: MoveTimeline(),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: EvaluationGraph(),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: ReviewSummaryCard(review: replay.review),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            16,
                            16,
                            MediaQuery.of(context).padding.bottom + 20,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: CriticalMomentCard(
                              review: replay.review.criticalMistake,
                              onTap: () {
                                final move =
                                    replay.review.criticalMistake?.moveNumber;
                                if (move != null) replay.jumpToMove(move);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}

class _ReplayBoardShell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final boardSize = (screen.width - 32).clamp(260.0, 560.0).toDouble();
    return Center(
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: const _ReplayBoard(),
      ),
    );
  }
}

class _ReplayBoard extends StatelessWidget {
  const _ReplayBoard();

  @override
  Widget build(BuildContext context) {
    final state = context.select((ReplayProvider provider) => provider.state);
    final appModel = context.read<AppModel>();
    final latestMove = state.latestMove;

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        itemBuilder: (context, index) {
          final tile =
              appModel.playingWithAI && appModel.playerSide == Player.player2
                  ? 63 - index
                  : index;
          final piece = state.board.tiles[tile];
          final highlighted = latestMove != null &&
              (latestMove.from == tile || latestMove.to == tile);
          final isLight = (tile + tile ~/ 8).isEven;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            color: highlighted
                ? AppColors.secondary.withValues(alpha: 0.64)
                : isLight
                    ? appModel.theme.lightTile
                    : appModel.theme.darkTile,
            child: piece == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      _pieceAsset(piece, appModel.pieceTheme),
                      fit: BoxFit.contain,
                    ),
                  ),
          );
        },
      ),
    );
  }

  String _pieceAsset(ChessPiece piece, String pieceTheme) {
    final color = piece.player == Player.player1 ? 'white' : 'black';
    final pieceName = piece.type == ChessPieceType.promotion
        ? 'pawn'
        : pieceTypeToString(piece.type);
    return 'assets/images/pieces/${formatPieceTheme(pieceTheme)}/${pieceName}_$color.png';
  }
}

class _ReplayEmptyState extends StatelessWidget {
  final String message;

  const _ReplayEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body1(context),
        ),
      ),
    );
  }
}
