import 'package:flutter/material.dart';
import 'package:en_passant/models/player.dart';
import 'package:en_passant/widgets/main_menu_view/game_options/picker.dart';

class SidePicker extends StatelessWidget {
  final Player playerSide;
  final Function(Player?) setFunc;

  const SidePicker(this.playerSide, this.setFunc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Picker<Player>(
      label: 'PLAY AS',
      selection: playerSide,
      setFunc: setFunc,
      options: const {
        Player.player1: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle_outlined),
            SizedBox(width: 6),
            Text('White'),
          ],
        ),
        Player.player2: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle),
            SizedBox(width: 6),
            Text('Black'),
          ],
        ),
        Player.random: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shuffle_rounded),
            SizedBox(width: 6),
            Text('Random'),
          ],
        ),
      },
    );
  }
}
