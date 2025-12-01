import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isMismatch =>
      _confirmController.text.isNotEmpty &&
      _newController.text != _confirmController.text;

  bool get _canSubmit =>
      _newController.text.length >= 6 &&
      _confirmController.text.length >= 6 &&
      !_isMismatch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit ? _handleReset : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset Password',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: JuselSpacing.s12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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
              const _UserCard(),
              const SizedBox(height: JuselSpacing.s12),
              const _InfoBanner(
                text:
                    'You are resetting the password for John Doe. The apprentice will use these new credentials to log in.',
              ),
              const SizedBox(height: JuselSpacing.s16),
              _PasswordField(
                label: 'New Password',
                hint: 'Enter new password',
                controller: _newController,
                obscure: !_showNew,
                toggle: () => setState(() => _showNew = !_showNew),
              ),
              const SizedBox(height: JuselSpacing.s16),
              _PasswordField(
                label: 'Confirm Password',
                hint: 'Re-enter password',
                controller: _confirmController,
                obscure: !_showConfirm,
                toggle: () => setState(() => _showConfirm = !_showConfirm),
                errorText: _isMismatch ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: JuselSpacing.s12),
              Row(
                children: [
                  const Icon(Icons.security,
                      size: 16, color: JuselColors.mutedForeground),
                  const SizedBox(width: 6),
                  Text(
                    'Minimum 6 characters required.',
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: JuselColors.mutedForeground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReset() {
    // TODO: Hook to reset password service.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset'),
        backgroundColor: JuselColors.success,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback toggle;
  final String? errorText;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.toggle,
    this.errorText,
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
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: JuselColors.mutedForeground,
              ),
              onPressed: toggle,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? JuselColors.destructive : JuselColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? JuselColors.destructive : JuselColors.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: JuselSpacing.s6),
            child: Text(
              errorText!,
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.destructive,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE5ECF9),
              child: Text(
                'JD',
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: JuselColors.foreground,
                ),
              ),
            ),
            const SizedBox(width: JuselSpacing.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Apprentice',
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: JuselColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: JuselSpacing.s8),
                    Text(
                      '+1 555 0123',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;

  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: JuselColors.primary,
          ),
          const SizedBox(width: JuselSpacing.s8),
          Expanded(
            child: Text(
              text,
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
