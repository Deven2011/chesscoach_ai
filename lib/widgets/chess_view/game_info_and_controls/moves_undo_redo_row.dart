import 'package:flutter/material.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls/moves_undo_redo_row/move_list.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls/moves_undo_redo_row/undo_redo_buttons.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class MovesUndoRedoRow extends StatelessWidget {
  final AppModel appModel;

  const MovesUndoRedoRow(this.appModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    if (!appModel.showMoveHistory && !appModel.allowUndoRedo) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: AppScaffold.elementSpacing * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (appModel.showMoveHistory)
            Expanded(
              flex: 3,
              child: MoveList(appModel),
            ),
          if (appModel.showMoveHistory && appModel.allowUndoRedo)
            SizedBox(width: AppScaffold.elementSpacing * scale),
          if (appModel.allowUndoRedo)
            Expanded(
              flex: 2,
              child: UndoRedoButtons(appModel),
            ),
        ],
      ),
    );
  }
}
