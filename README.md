# ChessCoach AI

ChessCoach AI is a Flutter chess application that combines a complete playable chess game, a Flame-powered board, AI opponents, player analytics, daily tactical puzzles, replay review, Firebase authentication, offline-first sync, and a personalized coaching dashboard.

The project began as a polished offline chess app and has been expanded into a training-focused chess companion with match history, progress tracking, coach insights, and puzzle progression.

## Highlights

- Play chess against an AI opponent or in local two-player mode.
- Choose AI difficulty across 5 levels.
- Configure player side, time controls, hints, notation, board rotation, sound, and undo/redo.
- Render the chess board and pieces with Flame.
- Persist preferences and saved games locally.
- Authenticate users with Firebase Auth.
- Sync user profile, match history, analytics, coach reports, and puzzle progress with Cloud Firestore.
- Continue using cached data when offline.
- Review match history, analytics, replay timelines, and post-game feedback.
- Train with a daily chess puzzle system, XP, streaks, hints, tiers, and progress history.
- Personalize the experience with multiple board themes and piece themes.

## Current Feature Set

### Chess Gameplay

- Single-player games against the built-in chess AI.
- Offline two-player mode on the same device.
- Side selection: white, black, or random.
- Optional timed games.
- Legal move validation, check, checkmate, stalemate, and promotion handling.
- Move history with standard move notation support.
- Undo and redo support when enabled.
- Visual move hints, latest move indicators, check indicators, and optional board coordinates.
- Resume support for saved games.
- Audio feedback for moves and game outcomes.

### Chess AI

- 5 difficulty levels.
- Minimax search with alpha-beta pruning.
- Iterative deepening and move ordering.
- Quiescence search for tactical stability.
- Null move pruning and late move reductions.
- Transposition table support.
- Piece-square tables and opening book support.

Core AI files live in:

```text
lib/logic/move_calculation/
```

### Daily Puzzle System

The project includes a complete daily tactical puzzle module:

- Daily puzzle rotation.
- Puzzle validation using UCI move notation.
- Multi-move puzzle progress tracking.
- Tactical themes including checkmate, fork, pin, skewer, discovered attack, sacrifice, defense, and endgame tactics.
- Difficulty-based XP rewards.
- Streak tracking and streak bonuses.
- Tier progression from beginner levels toward advanced ranks.
- Hint system with up to 3 hints per puzzle.
- Puzzle result screen with completion feedback.
- Puzzle history and performance analytics.
- Firestore-backed attempt and progress persistence.

Puzzle implementation is organized under:

```text
lib/puzzles/
lib/models/puzzle_*.dart
lib/providers/puzzle_provider.dart
lib/screens/puzzles/
lib/widgets/puzzles/
```

### Analytics And Match History

ChessCoach AI tracks completed matches and turns them into useful progress data:

- Total matches, wins, losses, draws, and win rate.
- Current streak tracking.
- Average game duration.
- Recent match list.
- Match metadata including game mode, AI difficulty, player color, duration, move count, result, opening family, and move history.
- Cached analytics for offline viewing.
- Firestore analytics summary persistence.

Analytics files include:

```text
lib/models/analytics_model.dart
lib/providers/analytics_provider.dart
lib/screens/analytics/
lib/widgets/analytics/
```

### AI Coach

The AI Coach layer analyzes match patterns and converts them into coaching insights:

- Personalized summary cards.
- Strengths, weaknesses, tendencies, and recommendations.
- Opening, pace, aggression, defense, and phase-oriented observations.
- Cached coach insights for offline access.
- Firestore persistence with sync queue fallback.
- Dashboard and action screens for training guidance.

Coach files include:

```text
lib/ai_coach/
lib/providers/ai_coach_provider.dart
lib/providers/realtime_coach_provider.dart
lib/screens/coach/
lib/widgets/coach/
```

### Replay And Post-Game Review

The replay system supports game review and learning after a match:

- Move timeline.
- Replay controls.
- Evaluation graph.
- Critical moment cards.
- Review summary cards.
- Move quality classification.
- Post-game analysis with accuracy, blunders, mistakes, best move streak, strongest phase, weakest phase, and coach summary.

Replay files include:

```text
lib/replay/
lib/providers/replay_provider.dart
lib/screens/replay/
lib/widgets/replay/
```

### Authentication, Cloud Sync, And Offline Support

The app is wired for authenticated user data and resilient offline behavior:

- Firebase initialization at app startup.
- Firebase Auth email/password sign up, sign in, sign out, and password reset.
- Cloud Firestore profile, match history, analytics, coach, and puzzle data.
- Firestore local persistence enabled with unlimited cache.
- Local SharedPreferences cache for user profile, match history, analytics, puzzle progress, coach insights, replay data, settings, and sync queue.
- Connectivity polling and an offline banner.
- Retry and no-connection UI components.
- Sync queue for actions that fail while offline.

Relevant files include:

```text
lib/firebase/
lib/providers/auth_provider.dart
lib/providers/connectivity_provider.dart
lib/services/
lib/widgets/shared/offline_banner.dart
lib/widgets/shared/sync_status_indicator.dart
```

### Customization

Board themes:

- Amoled
- Cherry Funk
- Dark
- Grey
- Jargon Jade
- Lewis
- Sage
- Warm Tan

Piece themes:

- 8-Bit
- Angular
- Classic
- Letters
- Lewis Chessmen
- Mexico City
- Video Chess

User preferences are saved locally:

- App theme
- Piece theme
- Move history visibility
- Sound
- Hints
- Board notation
- Board rotation
- Undo/redo availability
- Basic local stats

## Technology Stack

- Flutter and Dart
- Flame for 2D chess board rendering
- Provider for state management
- Firebase Core
- Firebase Auth
- Cloud Firestore
- SharedPreferences for local persistence
- Flame Audio for sound effects
- fl_chart for analytics and review charts
- Google Fonts and bundled Jura font
- Confetti for completion feedback

## Project Structure

```text
lib/
  main.dart                         App startup, Firebase, Flame assets, providers
  core/theme/                       App colors, typography, and Material theme
  firebase/                         Auth and Firestore service layer
  logic/                            Chess engine, board, game controller, timers, audio
  logic/move_calculation/           Move generation and chess AI
  models/                           App, user, match, analytics, puzzle, coach, replay models
  providers/                        Provider-based application state
  screens/                          Main screens and feature screens
  widgets/                          Reusable and feature-specific UI components
  puzzles/                          Daily puzzle engine, generator, validator, progress tracker
  ai_coach/                         Coaching and move analysis engines
  replay/                           Replay timeline and post-game analysis engines

assets/
  audio/                            Move and result sound effects
  font/                             Jura font
  icons/                            Launcher icon assets
  images/                           Logo and chess piece themes

android/                            Android platform project
ios/                                iOS platform project
```

## App Startup Flow

1. Flutter bindings initialize.
2. Portrait orientation is locked.
3. Firebase is initialized from `lib/firebase_options.dart`.
4. Firestore offline persistence is enabled.
5. Flame preloads chess piece sprites and audio assets.
6. The app registers providers through `MultiProvider`.
7. `AuthGate` decides whether to show authentication screens or the main app.
8. `OfflineBanner` wraps the app and reports connectivity state.

## Setup

### Prerequisites

- Flutter SDK with Dart 3.0 or newer.
- Android Studio or Xcode for platform builds.
- A configured Firebase project for Auth and Firestore.
- Platform Firebase config files:
  - `android/app/google-services.json`
  - iOS Firebase configuration through `lib/firebase_options.dart` and the iOS runner setup.

### Install Dependencies

```bash
flutter pub get
```

### Run The App

```bash
flutter run
```

### Analyze The Project

```bash
flutter analyze
```

### Build Android

```bash
flutter build apk --release
```

For signed release builds, configure `android/key.properties` with the release keystore values expected by `android/app/build.gradle`.

### Build iOS

```bash
flutter build ios --release
```

Open the iOS project in Xcode for signing and distribution settings when needed.

## Firebase Data Model

The Firestore service stores user data under:

```text
users/{userId}
  match_history/{matchId}
  analytics/summary
  coach_insights/{insightId}
  ai_coach/summary
  puzzle_attempts/{attemptId}
  puzzles/progress
```

## Important Development Notes

- Global application state should stay in Provider-backed classes, especially `AppModel` for core game state.
- Chess rule and AI changes should be kept inside `lib/logic/`.
- Minimax depth, alpha-beta pruning, move generation, transposition tables, and pruning optimizations should be handled carefully.
- New piece themes must be added to `PIECE_THEMES` in `lib/models/user_preferences.dart`, placed under `assets/images/pieces/<theme_name>/`, and included in `pubspec.yaml`.
- Do not remove undo/redo, timers, difficulty levels, or saved-game behavior unless intentionally changing the product scope.
- Keep Dart files formatted with `dart format`.

## Assets

The app includes:

- Chess piece sprites for 7 piece styles.
- App logo and launcher icons.
- Move, win, loss, and tie sound effects.
- Jura variable font.

Flutter asset registration is in `pubspec.yaml`.

## What Has Been Accomplished

- Built a full Flutter chess game with Flame rendering.
- Added local single-player and two-player gameplay.
- Implemented AI difficulty levels with a serious chess search stack.
- Added saved games, timers, move history, undo/redo, hints, notation, sound, and board rotation.
- Added multiple board and piece themes.
- Migrated the app toward a professional training product named ChessCoach AI.
- Added Firebase Auth and Firestore-backed user data.
- Added offline cache and sync queue support.
- Added connectivity detection and offline UI.
- Added match history and analytics.
- Added AI Coach insights, recommendations, strengths, weaknesses, and tendencies.
- Added replay, post-game analysis, move quality feedback, evaluation graphing, and critical moment review.
- Added a complete daily puzzle system with progress, XP, streaks, hints, result screens, history, and tactical categories.
- Added a shared theme system and reusable app scaffolding.
- Added Android app identity, launcher assets, Firebase config, and release signing hooks.

## Roadmap Ideas

- Expand the puzzle database beyond bundled sample puzzles.
- Add leaderboard and challenge modes.
- Add richer engine-backed move recommendations.
- Add cloud device-to-device saved-game resume.
- Add achievement badges.
- Add deeper opening classification.
- Add more automated tests around move validation, AI search, puzzle validation, sync, and analytics.

## Repository Notes

Package name: `en_passant`

Application title: `ChessCoach AI`

Android application id: `com.harshvardhan.chesscoachai`

Current app version in `pubspec.yaml`: `1.0.2+3`
