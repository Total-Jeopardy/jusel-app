import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

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
            onPressed: _canSubmit ? _handleSubmit : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
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
                      ),
                      const SizedBox(height: JuselSpacing.s16),
                      _PasswordField(
                        label: 'New Password',
                        controller: _newController,
                        obscure: !_showNew,
                        toggle: () => setState(() => _showNew = !_showNew),
                        helper: 'Password must be at least 6 characters.',
                      ),
                      const SizedBox(height: JuselSpacing.s16),
                      _PasswordField(
                        label: 'Confirm New Password',
                        controller: _confirmController,
                        obscure: !_showConfirm,
                        toggle: () =>
                            setState(() => _showConfirm = !_showConfirm),
                        errorText: _isMismatch ? 'Passwords do not match' : null,
                        borderColor: _isMismatch ? JuselColors.destructive : null,
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

  void _handleSubmit() {
    // TODO: Hook to change password service.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated'),
        backgroundColor: JuselColors.success,
      ),
    );
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

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.toggle,
    this.helper,
    this.errorText,
    this.borderColor,
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
          onChanged: (_) {},
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
