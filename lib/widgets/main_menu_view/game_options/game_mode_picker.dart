import 'package:flutter/material.dart';
import 'package:en_passant/widgets/main_menu_view/game_options/picker.dart';

class GameModePicker extends StatelessWidget {
  final int playerCount;
  final Function(int?) setFunc;

  const GameModePicker(this.playerCount, this.setFunc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Picker<int>(
      label: 'GAME MODE',
      selection: playerCount,
      setFunc: setFunc,
      options: const {
        1: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_rounded),
            SizedBox(width: 6),
            Text('Play vs AI'),
          ],
        ),
        2: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_alt_rounded),
            SizedBox(width: 6),
            Text('2 Player Local'),
          ],
        ),
      },
    );
  }
}
