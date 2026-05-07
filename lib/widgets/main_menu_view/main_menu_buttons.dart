import 'package:flutter/material.dart';

import 'package:en_passant/logic/game_state_storage.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/screens/chess_view.dart';
import 'package:en_passant/screens/settings_view.dart';
import 'package:en_passant/widgets/shared/rounded_button.dart';

class MainMenuButtons extends StatefulWidget {
  final AppModel appModel;

  MainMenuButtons(this.appModel);

  @override
  _MainMenuButtonsState createState() => _MainMenuButtonsState();
}

class _MainMenuButtonsState extends State<MainMenuButtons> {
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  void _checkSavedGame() async {
    final hasSaved = await GameStateStorage.hasSavedGame();
    if (mounted) {
      setState(() {
        _hasSavedGame = hasSaved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          if (_hasSavedGame) ...[
            RoundedButton(
              'Resume Game',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ChessView(widget.appModel, isResuming: true);
                    },
                  ),
                ).then((_) => _checkSavedGame());
              },
            ),
            SizedBox(height: 10),
          ],
          RoundedButton(
            'Start',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ChessView(widget.appModel);
                  },
                ),
              ).then((_) => _checkSavedGame());
            },
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RoundedButton(
                  'Settings',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsView(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
