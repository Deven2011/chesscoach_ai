import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/providers/auth_provider.dart';
import 'package:en_passant/screens/auth/login_screen.dart';
import 'package:en_passant/screens/main_menu_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, ({bool isInitializing, bool isLoggedIn})>(
      selector: (_, provider) => (
        isInitializing: provider.isInitializing,
        isLoggedIn: provider.isLoggedIn,
      ),
      builder: (context, state, child) {
        if (state.isInitializing) {
          return const _AuthLoadingScreen();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 360),
          switchInCurve: Curves.easeOutQuart,
          switchOutCurve: Curves.easeInQuart,
          child: state.isLoggedIn
              ? const MainMenuView(key: ValueKey('main-menu'))
              : const LoginScreen(key: ValueKey('login')),
        );
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 18),
            Text(
              'Preparing your board',
              style: AppTextStyles.textTheme().titleMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
