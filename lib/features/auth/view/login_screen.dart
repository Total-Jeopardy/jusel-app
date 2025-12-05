import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jusel_app/core/ui/components/jusel_button.dart';
import 'package:jusel_app/core/ui/components/jusel_card.dart';
import 'package:jusel_app/core/ui/components/jusel_text_field.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    await ref.read(authViewModelProvider.notifier).signIn(email, password);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null && mounted) {
        final destination = user.role == 'boss'
            ? '/boss-dashboard'
            : '/apprentice-dashboard';
        context.go(destination);
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final initialUserExists = ref
        .watch(initialUserExistsProvider)
        .maybeWhen(data: (value) => value, orElse: () => true);
    final isLoading = authState.isLoading;
    final errorMessage = authState.whenOrNull(error: (e, st) => e.toString());

    return Scaffold(
      backgroundColor: JuselColors.background,
      body: Stack(
        children: [
          // Background gradient / shapes
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE9F0FF), Color(0xFFF8FAFF)],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: JuselColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: JuselColors.secondary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: JuselSpacing.s20,
                        vertical: JuselSpacing.s24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jusel',
                                  style: JuselTextStyles.headlineMedium
                                      .copyWith(
                                        color: JuselColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: JuselSpacing.s8),
                                const Text(
                                  'Welcome back',
                                  style: JuselTextStyles.headlineLarge,
                                ),
                                const SizedBox(height: JuselSpacing.s6),
                                Text(
                                  'Sign in to continue managing sales and stock.',
                                  style: JuselTextStyles.bodyMedium.copyWith(
                                    color: JuselColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: JuselSpacing.s24),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: JuselCard(
                              padding: JuselCardPadding.lg,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _LoginForm(
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    errorMessage: errorMessage,
                                    isLoading: isLoading,
                                  ),
                                  const SizedBox(height: JuselSpacing.s16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'New here?',
                                        style: JuselTextStyles.bodyMedium
                                            .copyWith(
                                              color:
                                                  JuselColors.mutedForeground,
                                            ),
                                      ),
                                      JuselButton(
                                        label: initialUserExists
                                            ? 'Create new account'
                                            : 'Create first account',
                                        variant: JuselButtonVariant.outline,
                                        size: JuselButtonSize.small,
                                        onPressed: isLoading
                                            ? null
                                            : () => context.go('/first-setup'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: JuselSpacing.s12),
                                  JuselButton(
                                    label: isLoading
                                        ? 'Signing in...'
                                        : 'Login',
                                    variant: JuselButtonVariant.primary,
                                    size: JuselButtonSize.large,
                                    isFullWidth: true,
                                    onPressed: isLoading ? null : _handleLogin,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? errorMessage;
  final bool isLoading;

  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    this.errorMessage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        JuselTextField(
          label: 'Email',
          hint: 'e.g. john@example.com',
          type: JuselTextFieldType.standard,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
        ),
        const SizedBox(height: JuselSpacing.s16),
        JuselTextField(
          label: 'Password',
          hint: 'Enter password',
          type: JuselTextFieldType.password,
          controller: passwordController,
          enabled: !isLoading,
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: JuselSpacing.s8,
            left: JuselSpacing.s4,
          ),
          child: Text(
            'Minimum 6 characters.',
            style: JuselTextStyles.bodySmall.copyWith(
              color: JuselColors.mutedForeground,
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: JuselSpacing.s16),
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 16,
                color: JuselColors.destructive,
              ),
              const SizedBox(width: JuselSpacing.s8),
              Expanded(
                child: Text(
                  errorMessage!,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.destructive,
                  ),
                ),
              ),
            ],
          ),
        ] else
          const SizedBox(height: JuselSpacing.s16),
      ],
    );
  }
}
