import 'package:flutter/material.dart';
import 'package:jusel_app/core/ui/components/success_overlay.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';

class ChangePasswordPlaceholderScreen extends StatefulWidget {
  const ChangePasswordPlaceholderScreen({super.key});

  @override
  State<ChangePasswordPlaceholderScreen> createState() =>
      _ChangePasswordPlaceholderScreenState();
}

class _ChangePasswordPlaceholderScreenState
    extends State<ChangePasswordPlaceholderScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _errorText;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final newPassword = _newController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    setState(() {
      if (newPassword.length < 6) {
        _errorText = 'Password must be at least 6 characters.';
      } else if (newPassword != confirmPassword) {
        _errorText = 'Passwords do not match';
      } else {
        _errorText = null;
        SuccessOverlay.show(context, message: 'Password updated');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          final horizontalPadding = isNarrow ? 20.0 : 32.0;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(JuselSpacing.s16),
                      decoration: BoxDecoration(
                        color: JuselColors.card(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: JuselColors.border(context)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Current Password'),
                          const SizedBox(height: JuselSpacing.s6),
                          _PasswordField(
                            controller: _currentController,
                            obscureText: _obscureCurrent,
                            onToggle: () => setState(
                              () => _obscureCurrent = !_obscureCurrent,
                            ),
                          ),
                          const SizedBox(height: JuselSpacing.s16),
                          const _FieldLabel('New Password'),
                          const SizedBox(height: JuselSpacing.s6),
                          _PasswordField(
                            controller: _newController,
                            obscureText: _obscureNew,
                            onToggle: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                          const SizedBox(height: JuselSpacing.s6),
                          Text(
                            'Password must be at least 6 characters.',
                            style: JuselTextStyles.bodySmall(context).copyWith(
                              color: JuselColors.mutedForeground(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: JuselSpacing.s16),
                          const _FieldLabel('Confirm New Password'),
                          const SizedBox(height: JuselSpacing.s6),
                          _PasswordField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            onToggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            isError: _errorText == 'Passwords do not match',
                          ),
                          if (_errorText != null) ...[
                            const SizedBox(height: JuselSpacing.s8),
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 18,
                                  color: JuselColors.destructiveColor(context),
                                ),
                                const SizedBox(width: JuselSpacing.s6),
                                Expanded(
                                  child: Text(
                                    _errorText!,
                                    style: TextStyle(
                                      color: JuselColors.destructiveColor(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: JuselColors.primaryColor(context),
                          foregroundColor: JuselColors.primaryForeground,
                        ),
                        child: const Text(
                          'Update Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s16),
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

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;
  final bool isError;

  const _PasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggle,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isError
                ? JuselColors.destructiveColor(context)
                : JuselColors.border(context),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isError
                ? JuselColors.destructiveColor(context)
                : JuselColors.primaryColor(context),
            width: 1.2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: JuselColors.muted(context),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: JuselTextStyles.bodySmall(context).copyWith(
        color: JuselColors.mutedForeground(context),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}
