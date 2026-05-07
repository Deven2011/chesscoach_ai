import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../models/app_model.dart';
import '../../../models/player.dart';
import '../../shared/app_scaffold.dart';
import 'timer_widget.dart';

class Timers extends StatelessWidget {
  final AppModel appModel;

  const Timers(this.appModel, {super.key});

  @override
  Widget build(BuildContext context) {
    if (appModel.timeLimit == 0) return const SizedBox.shrink();

    final scale = AppTextStyles.responsiveScale(context);
    final playerTimer = _timerForPlayer(appModel, appModel.playerSide);
    final aiTimer = _timerForPlayer(appModel, appModel.aiTurn);

    return Padding(
      padding: EdgeInsets.only(bottom: AppScaffold.elementSpacing * scale),
      child: Row(
        children: [
          TimerWidget(
            timeLeft:
                appModel.playingWithAI ? playerTimer : appModel.player1TimeLeft,
            color: appModel.playingWithAI
                ? _clockColor(appModel.playerSide)
                : Colors.white,
            label: appModel.playerCount == 1 ? 'YOU' : 'WHITE',
          ),
          SizedBox(width: AppScaffold.elementSpacing * scale),
          TimerWidget(
            timeLeft:
                appModel.playingWithAI ? aiTimer : appModel.player2TimeLeft,
            color: appModel.playingWithAI
                ? _clockColor(appModel.aiTurn)
                : Colors.black,
            label: appModel.playerCount == 1 ? 'AI' : 'BLACK',
          ),
        ],
      ),
    );
  }

  ValueNotifier<Duration> _timerForPlayer(AppModel appModel, Player player) {
    return player == Player.player1
        ? appModel.player1TimeLeft
        : appModel.player2TimeLeft;
  }

  Color _clockColor(Player player) {
    return player == Player.player1 ? Colors.white : Colors.black;
  }
}
