import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/firebase_options.dart';
import 'package:en_passant/logic/shared_functions.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/user_preferences.dart';
import 'package:en_passant/providers/ai_coach_provider.dart';
import 'package:en_passant/providers/analytics_provider.dart';
import 'package:en_passant/providers/auth_provider.dart';
import 'package:en_passant/providers/match_history_provider.dart';
import 'package:en_passant/screens/auth/auth_gate.dart';
import 'package:en_passant/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _loadFlameAssets();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppModel()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MatchHistoryProvider>(
          create: (context) => MatchHistoryProvider(),
          update: (context, auth, provider) {
            final history = provider ?? MatchHistoryProvider();
            history.bindUser(auth.user?.uid);
            return history;
          },
        ),
        ChangeNotifierProxyProvider2<AuthProvider, MatchHistoryProvider,
            AnalyticsProvider>(
          create: (context) => AnalyticsProvider(),
          update: (context, auth, history, provider) {
            final analytics = provider ?? AnalyticsProvider();
            analytics.bindUser(auth.user?.uid, history.matches);
            return analytics;
          },
        ),
        ChangeNotifierProxyProvider2<AuthProvider, MatchHistoryProvider,
            AiCoachProvider>(
          create: (context) => AiCoachProvider(),
          update: (context, auth, history, provider) {
            final coach = provider ?? AiCoachProvider();
            coach.bindUser(auth.user?.uid, history.matches);
            return coach;
          },
        ),
      ],
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
      home: const AuthGate(),
    );
  }
}
