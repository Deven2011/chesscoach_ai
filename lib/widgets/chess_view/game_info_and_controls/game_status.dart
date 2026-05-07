import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/player.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

/// State tuple for GameStatus — only rebuilds when these fields change.
typedef _StatusState = ({
  bool gameOver,
  int playerCount,
  bool isAIsTurn,
  Player turn,
  bool stalemate,
  int aiDifficulty,
});

class GameStatus extends StatelessWidget {
  const GameStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return Selector<AppModel, _StatusState>(
      selector: (_, m) => (
        gameOver: m.gameOver,
        playerCount: m.playerCount,
        isAIsTurn: m.isAIsTurn,
        turn: m.turn,
        stalemate: m.stalemate,
        aiDifficulty: m.aiDifficulty,
      ),
      builder: (context, state, child) {
        final statusText = _getStatus(state);
        final isThinkng = !state.gameOver && state.playerCount == 1 && state.isAIsTurn;

        return Container(
          padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 20 * scale),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isThinkng ? AppColors.primary.withOpacity(0.3) : AppColors.border.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isThinkng) ...[
                SizedBox(
                  width: 12 * scale,
                  height: 12 * scale,
                  child: CircularProgressIndicator(
                    strokeWidth: 2 * scale,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                SizedBox(width: 12 * scale),
              ],
              Text(
                statusText,
                style: AppTextStyles.body2(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: isThinkng ? AppColors.primaryLight : AppColors.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatus(_StatusState s) {
    if (!s.gameOver) {
      if (s.playerCount == 1) {
        if (s.isAIsTurn) {
          return 'AI THINKING...';
        } else {
          return 'YOUR TURN';
        }
      } else {
        return s.turn == Player.player1 ? 'WHITE\'S TURN' : 'BLACK\'S TURN';
      }
    } else {
      if (s.stalemate) {
        return 'DRAW (STALEMATE)';
      } else {
        if (s.playerCount == 1) {
          return s.isAIsTurn ? 'VICTORY!' : 'DEFEAT';
        } else {
          return s.turn == Player.player1 ? 'BLACK WINS' : 'WHITE WINS';
        }
      }
    }
  }
}
