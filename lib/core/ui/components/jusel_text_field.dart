import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

enum JuselTextFieldType { standard, password, email, number }

class JuselTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final JuselTextFieldType type;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const JuselTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.type = JuselTextFieldType.standard,
    this.keyboardType,
    this.enabled = true,
    this.errorText,
    this.onChanged,
  });

  @override
  State<JuselTextField> createState() => _JuselTextFieldState();
}

class _JuselTextFieldState extends State<JuselTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.type == JuselTextFieldType.password;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: JuselTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType ??
              (widget.type == JuselTextFieldType.number
                  ? TextInputType.number
                  : TextInputType.text),
          obscureText: isPassword && _obscureText,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}




