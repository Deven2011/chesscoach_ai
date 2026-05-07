import 'package:flutter/material.dart';
import 'package:en_passant/logic/chess_piece.dart';
import 'package:en_passant/logic/shared_functions.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/player.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class PromotionOption extends StatelessWidget {
  final AppModel appModel;
  final ChessPieceType promotionType;

  const PromotionOption(this.appModel, this.promotionType, {super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          appModel.gameController!.promote(promotionType);
          appModel.update();
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16 * scale),
        child: Container(
          width: 70 * scale,
          height: 70 * scale,
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Image(
              height: 44 * scale,
              width: 44 * scale,
              image: AssetImage(
                'assets/images/pieces/${formatPieceTheme(appModel.pieceTheme)}' +
                    '/${pieceTypeToString(promotionType)}_${_playerColor()}.png',
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _playerColor() {
    return appModel.turn == Player.player1 ? 'white' : 'black';
  }
}
