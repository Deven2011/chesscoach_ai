import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/logic/shared_functions.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/user_preferences.dart';
import 'package:en_passant/screens/main_menu_view.dart';
import 'package:en_passant/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await _loadFlameAssets();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppModel(),
      child: const Chess(),
    ),
  );
}

Future<void> _loadFlameAssets() async {
  List<String> pieceImages = [];
  for (var theme in PIECE_THEMES) {
    for (var color in ['black', 'white']) {
      for (var piece in ['king', 'queen', 'rook', 'bishop', 'knight', 'pawn']) {
        pieceImages
            .add('pieces/${formatPieceTheme(theme)}/${piece}_$color.png');
      }
    }
  }
  await Flame.images.loadAll(pieceImages);
  await FlameAudio.audioCache.loadAll([
    'piece_moved.mp3',
    'win.wav',
    'lose.wav',
    'tie.wav',
  ]);
}

class Chess extends StatelessWidget {
  const Chess({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChessCoach AI',
      theme: AppTheme.darkTheme,
      home: MainMenuView(),
    );
  }
}
