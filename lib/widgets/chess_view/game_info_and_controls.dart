import 'package:flutter/material.dart';

import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls/moves_undo_redo_row.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls/restart_exit_buttons.dart';
import 'package:en_passant/widgets/chess_view/game_info_and_controls/timers.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class GameInfoAndControls extends StatelessWidget {
  final AppModel appModel;

  const GameInfoAndControls(this.appModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        16 * scale,
        20 * scale,
        (16 * scale) + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Timers(appModel),
          MovesUndoRedoRow(appModel),
          RestartExitButtons(appModel),
        ],
      ),
    );
  }
}
