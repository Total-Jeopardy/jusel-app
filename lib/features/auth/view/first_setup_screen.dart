import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/ui/components/jusel_app_bar.dart';
import 'package:jusel_app/core/ui/components/jusel_button.dart';
import 'package:jusel_app/core/ui/components/jusel_card.dart';
import 'package:jusel_app/core/ui/components/jusel_text_field.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

class FirstSetupScreen extends ConsumerStatefulWidget {
  const FirstSetupScreen({super.key});

  @override
  ConsumerState<FirstSetupScreen> createState() => _FirstSetupScreenState();
}

class _FirstSetupScreenState extends ConsumerState<FirstSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'boss';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final initialExists = ref.read(initialUserExistsProvider).maybeWhen(
          data: (value) => value,
          orElse: () => true,
        );

    if (initialExists) {
      await ref.read(authViewModelProvider.notifier).signUpAdditionalUser(
            name: name,
            phone: phone,
            email: email,
            password: password,
            role: _role,
          );
    } else {
      await ref.read(authViewModelProvider.notifier).signUpFirstUser(
            name: name,
            phone: phone,
            email: email,
            password: password,
            role: _role,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final initialExists = ref.watch(initialUserExistsProvider).maybeWhen(
          data: (value) => value,
          orElse: () => true,
        );
    final isLoading = authState.isLoading;
    final errorMessage =
        authState.whenOrNull(error: (e, st) => e.toString());

    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: const JuselAppBar(
        title: 'Create account',
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      padding: const EdgeInsets.symmetric(
                        horizontal: JuselSpacing.s20,
                      ),
                      child: JuselCard(
                        padding: JuselCardPadding.lg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              initialExists
                                  ? 'Create a new account'
                                  : 'Create the first account',
                              style: JuselTextStyles.headlineMedium,
                            ),
                            const SizedBox(height: JuselSpacing.s12),
                            Text(
                              initialExists
                                  ? 'Forgot password? Create another account and continue.'
                                  : 'This runs only once. Choose a role (boss or apprentice).',
                              style: JuselTextStyles.bodyMedium.copyWith(
                                color: JuselColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: JuselSpacing.s24),
                            JuselTextField(
                              label: 'Full name',
                              hint: 'e.g. Jane Doe',
                              controller: _nameController,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: JuselSpacing.s16),
                            JuselTextField(
                              label: 'Phone',
                              hint: 'e.g. 08012345678',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: JuselSpacing.s16),
                            JuselTextField(
                              label: 'Email',
                              hint: 'e.g. jane@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: JuselSpacing.s16),
                            JuselTextField(
                              label: 'Password',
                              hint: 'Minimum 6 characters',
                              type: JuselTextFieldType.password,
                              controller: _passwordController,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: JuselSpacing.s16),
                            DropdownButtonFormField<String>(
                              initialValue: _role,
                              decoration: const InputDecoration(
                                labelText: 'Role',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'boss',
                                  child: Text('Boss'),
                                ),
                                DropdownMenuItem(
                                  value: 'apprentice',
                                  child: Text('Apprentice'),
                                ),
                              ],
                              onChanged: isLoading
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() => _role = val);
                                      }
                                    },
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
                                      errorMessage,
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
                        ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s32),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      padding: const EdgeInsets.symmetric(
                        horizontal: JuselSpacing.s20,
                      ),
                      child: SafeArea(
                        child: JuselButton(
                          label: isLoading ? 'Creating...' : 'Create account',
                          variant: JuselButtonVariant.primary,
                          size: JuselButtonSize.large,
                          isFullWidth: true,
                          onPressed: isLoading ? null : _handleCreate,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
