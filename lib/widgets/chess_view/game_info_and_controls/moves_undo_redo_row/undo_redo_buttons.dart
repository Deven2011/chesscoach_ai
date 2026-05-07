import 'package:flutter/material.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls/moves_undo_redo_row/rounded_icon_button.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class UndoRedoButtons extends StatelessWidget {
  final AppModel appModel;

  const UndoRedoButtons(this.appModel, {super.key});

  bool get undoEnabled {
    return appModel.gameController != null &&
        appModel.gameController!.board.moveStack.isNotEmpty &&
        (!appModel.playingWithAI ||
            appModel.gameController!.board.moveStack.length > 1);
  }

  bool get redoEnabled {
    return appModel.gameController != null &&
        appModel.gameController!.board.redoStack.isNotEmpty &&
        (!appModel.playingWithAI ||
            appModel.gameController!.board.redoStack.length > 1);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return Row(
      children: [
        Expanded(
          child: RoundedIconButton(
            Icons.undo_rounded,
            tooltip: 'Undo',
            onPressed: undoEnabled ? () => _undo() : null,
          ),
        ),
        SizedBox(width: AppScaffold.elementSpacing * scale),
        Expanded(
          child: RoundedIconButton(
            Icons.redo_rounded,
            tooltip: 'Redo',
            onPressed: redoEnabled ? () => _redo() : null,
          ),
        ),
      ],
    );
  }

  void _undo() {
    if (appModel.gameController != null) {
      if (appModel.playingWithAI) {
        appModel.gameController!.undoTwoMoves();
      } else {
        appModel.gameController!.undoMove();
      }
      appModel.update();
    }
  }

  void _redo() {
    if (appModel.gameController != null) {
      if (appModel.playingWithAI) {
        appModel.gameController!.redoTwoMoves();
      } else {
        appModel.gameController!.redoMove();
      }
      appModel.update();
    }
  }
}
