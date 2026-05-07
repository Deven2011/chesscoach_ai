import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../models/app_model.dart';
import '../../shared/app_scaffold.dart';
import 'timer_widget.dart';

class Timers extends StatelessWidget {
  final AppModel appModel;

  const Timers(this.appModel, {super.key});

  @override
  Widget build(BuildContext context) {
    if (appModel.timeLimit == 0) return const SizedBox.shrink();

    final scale = AppTextStyles.responsiveScale(context);

    return Padding(
      padding: EdgeInsets.only(bottom: AppScaffold.elementSpacing * scale),
      child: Row(
        children: [
          TimerWidget(
            timeLeft: appModel.player1TimeLeft,
            color: Colors.white,
            label: appModel.playerCount == 1 ? 'YOU' : 'WHITE',
          ),
          SizedBox(width: AppScaffold.elementSpacing * scale),
          TimerWidget(
            timeLeft: appModel.player2TimeLeft,
            color: Colors.black,
            label: appModel.playerCount == 1 ? 'AI' : 'BLACK',
          ),
        ],
      ),
    );
  }
}
