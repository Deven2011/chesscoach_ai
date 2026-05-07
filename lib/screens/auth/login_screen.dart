import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/providers/auth_provider.dart';
import 'package:en_passant/screens/auth/auth_widgets.dart';
import 'package:en_passant/screens/auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return AuthScaffold(
      title: 'Welcome back',
      subtitle:
          'Sign in to continue your training, saved progress, and match history.',
      child: Selector<AuthProvider, bool>(
        selector: (_, provider) => provider.isLoading,
        builder: (context, isLoading, child) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: 16 * scale),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(height: 8 * scale),
                Align(
                  alignment: Alignment.centerRight,
                  child: AuthTextButton(
                    text: 'Forgot password?',
                    onPressed: isLoading ? null : _showForgotPasswordSheet,
                  ),
                ),
                SizedBox(height: 16 * scale),
                AuthPrimaryButton(
                  label: 'SIGN IN',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submit,
                ),
                SizedBox(height: 18 * scale),
                _AuthSwitchPrompt(
                  prompt: 'New to ChessCoach AI?',
                  action: 'Create account',
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, animation, __) =>
                                  const SignupScreen(),
                              transitionsBuilder: (_, animation, __, child) {
                                final curved = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutQuart,
                                );
                                return FadeTransition(
                                  opacity: curved,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.04, 0),
                                      end: Offset.zero,
                                    ).animate(curved),
                                    child: child,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted || success) return;
    _showMessage(auth.errorMessage ?? 'Unable to sign in.');
  }

  Future<void> _showForgotPasswordSheet() async {
    final emailController = TextEditingController(text: _emailController.text);
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            22,
            22,
            22 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reset password',
                  style: AppTextStyles.headline3(sheetContext).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email and Firebase will send a reset link.',
                  style: AppTextStyles.body2(sheetContext).copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                AuthTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 18),
                AuthPrimaryButton(
                  label: 'SEND RESET LINK',
                  icon: Icons.mark_email_read_rounded,
                  isLoading: false,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final auth = context.read<AuthProvider>();
                    final sent = await auth.sendPasswordResetEmail(
                      emailController.text,
                    );
                    if (!mounted || !sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    _showMessage(
                      sent
                          ? 'Password reset link sent.'
                          : auth.errorMessage ?? 'Could not send reset link.',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    emailController.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required.';
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _AuthSwitchPrompt extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback? onPressed;

  const _AuthSwitchPrompt({
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4 * scale,
      children: [
        Text(
          prompt,
          style: AppTextStyles.body2(context).copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        AuthTextButton(text: action, onPressed: onPressed),
      ],
    );
  }
}
