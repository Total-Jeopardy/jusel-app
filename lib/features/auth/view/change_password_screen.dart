import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isMismatch =>
      _confirmController.text.isNotEmpty &&
      _newController.text != _confirmController.text;

  bool get _canSubmit =>
      _currentController.text.isNotEmpty &&
      _newController.text.length >= 6 &&
      _confirmController.text.length >= 6 &&
      !_isMismatch;

  (String label, Color color)? get _strength {
    final pwd = _newController.text;
    if (pwd.isEmpty) return null;
    if (pwd.length < 6) {
      return ('Too short', JuselColors.destructive);
    }
    final hasLetters = RegExp(r'[A-Za-z]').hasMatch(pwd);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(pwd);
    final hasSymbols = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pwd);
    final score = [hasLetters, hasNumbers, hasSymbols].where((e) => e).length;
    if (score >= 3 && pwd.length >= 10) {
      return ('Strong password', JuselColors.success);
    }
    if (score >= 2) {
      return ('Good password', const Color(0xFFF59E0B));
    }
    return ('Weak password', JuselColors.destructive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuselColors.background,
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
        centerTitle: false,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting || !_canSubmit ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Update Password',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: JuselSpacing.s16),
              Card(
                margin: EdgeInsets.zero,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(JuselSpacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PasswordField(
                        label: 'Current Password',
                        controller: _currentController,
                        obscure: !_showCurrent,
                        toggle: () =>
                            setState(() => _showCurrent = !_showCurrent),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: JuselSpacing.s16),
                      _PasswordField(
                        label: 'New Password',
                        controller: _newController,
                        obscure: !_showNew,
                        toggle: () => setState(() => _showNew = !_showNew),
                        helper: 'Password must be at least 6 characters.',
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_strength != null) ...[
                        const SizedBox(height: JuselSpacing.s6),
                        Text(
                          _strength!.$1,
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: _strength!.$2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: JuselSpacing.s16),
                      _PasswordField(
                        label: 'Confirm New Password',
                        controller: _confirmController,
                        obscure: !_showConfirm,
                        toggle: () =>
                            setState(() => _showConfirm = !_showConfirm),
                        errorText: _isMismatch ? 'Passwords do not match' : null,
                        borderColor: _isMismatch ? JuselColors.destructive : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_isMismatch) ...[
                        const SizedBox(height: JuselSpacing.s12),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 18,
                              color: JuselColors.destructive,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Passwords do not match',
                              style: JuselTextStyles.bodySmall.copyWith(
                                color: JuselColors.destructive,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: JuselSpacing.s12),
                        Text(
                          _error!,
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: JuselColors.destructive,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: JuselSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'No authenticated user. Please sign in again.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      if (_currentController.text.isNotEmpty && user.email != null) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentController.text,
        );
        await user.reauthenticateWithCredential(cred);
      }

      await user.updatePassword(_newController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated'),
          backgroundColor: JuselColors.success,
        ),
      );
      safePop(context, fallbackRoute: '/boss-dashboard');
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to update password';
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'requires-recent-login':
          message = 'Please reauthenticate and try again.';
          break;
        case 'wrong-password':
          message = 'Current password is incorrect.';
          break;
        default:
          message = e.message ?? message;
      }
      if (mounted) {
        setState(() => _error = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: JuselColors.destructive,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update password: $e'),
            backgroundColor: JuselColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback toggle;
  final String? helper;
  final String? errorText;
  final Color? borderColor;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.toggle,
    this.helper,
    this.errorText,
    this.borderColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: JuselTextStyles.bodySmall.copyWith(
            color: JuselColors.mutedForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: JuselSpacing.s6),
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF4F7FB),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: borderColor ?? const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? JuselColors.destructive : JuselColors.primary,
                width: 1.2,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: JuselColors.mutedForeground,
              ),
              onPressed: toggle,
            ),
          ),
        ),
        if (helper != null && !hasError)
          Padding(
            padding: const EdgeInsets.only(top: JuselSpacing.s6),
            child: Text(
              helper!,
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
              ),
            ),
          ),
      ],
    );
  }
}
