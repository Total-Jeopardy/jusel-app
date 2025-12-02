import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImagePickerCard(),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('BASIC INFO'),
            _FieldCard(
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Product Name',
                    child: TextField(
                      decoration: _inputDecoration('e.g. Orange Juice 1L'),
                    ),
                  ),
                  _DividerRow(),
                  const _LabeledField(
                    label: 'Category',
                    child: _DropdownField(
                      value: 'Drinks',
                      items: ['Drinks', 'Snacks', 'Bakery'],
                    ),
                  ),
                  _DividerRow(),
                  const _LabeledField(
                    label: 'Subcategory',
                    child: _DropdownField(
                      value: 'Soft Drink',
                      items: ['Soft Drink', 'Juice', 'Water'],
                    ),
                  ),
                  _DividerRow(),
                  const _LabeledField(
                    label: 'Product Type',
                    child: _DisabledField(
                      text: 'Purchased (Auto-detected)',
                      icon: Icons.info_outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('PACK CONFIGURATION'),
            _FieldCard(
              child: Column(
                children: const [
                  _LabeledField(
                    label: 'Units per Pack',
                    child: _FilledInput(
                      hint: '6',
                      keyboardType: TextInputType.number,
                      trailingText: 'btls',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('INVENTORY'),
            _FieldCard(
              child: Column(
                children: const [
                  _LabeledField(
                    label: 'Initial Stock',
                    helper: 'Optional',
                    child: _FilledInput(
                      hint: '0',
                      keyboardType: TextInputType.number,
                      trailingText: 'units',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('PRICING'),
            _FieldCard(
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Selling Price',
                    child: _FilledInput(
                      hint: '\$ 0.00',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  _DividerRow(),
                  _LabeledField(
                    label: 'Cost Price',
                    trailing: _UnitTag(
                      'BOSS ONLY',
                      color: const Color(0xFF2563EB),
                    ),
                    child: _FilledInput(
                      hint: '\$ 0.00',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('SETTINGS'),
            _FieldCard(
              child: _ToggleRow(
                label: 'Product Status',
                helper: 'Available for sales',
                value: true,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: JuselSpacing.s20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: JuselSpacing.s12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: JuselColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save Product',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: JuselSpacing.s12),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s56),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.camera_alt_outlined, color: JuselColors.primary, size: 32),
          SizedBox(height: JuselSpacing.s8),
          Text(
            'Add Image',
            style: TextStyle(
              color: JuselColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: JuselSpacing.s8),
      child: Text(
        text,
        style: JuselTextStyles.bodySmall.copyWith(
          color: JuselColors.mutedForeground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final Widget child;
  const _FieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String? helper;
  final Widget child;
  final Widget? trailing;

  const _LabeledField({
    required this.label,
    required this.child,
    this.helper,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: JuselSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (helper != null)
                Text(
                  helper!,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (trailing != null) ...[
                const SizedBox(width: JuselSpacing.s6),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: JuselSpacing.s8),
          child,
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF2F6FF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
    ),
  );
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;

  const _DropdownField({required this.value, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(14),
        border: null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.expand_more,
            color: JuselColors.mutedForeground,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: JuselTextStyles.bodyMedium.copyWith(
                      color: JuselColors.foreground,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}

class _UnitTag extends StatelessWidget {
  final String text;
  final Color color;
  const _UnitTag(this.text, {this.color = JuselColors.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: JuselColors.muted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: JuselTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String helper;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.helper,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: JuselColors.foreground,
                ),
              ),
              Text(
                helper,
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: JuselColors.primary,
        ),
      ],
    );
  }
}

class _DividerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 16, color: Color(0xFFE5E7EB), thickness: 1);
  }
}

class _DisabledField extends StatelessWidget {
  final String text;
  final IconData icon;

  const _DisabledField({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7DFEB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: JuselTextStyles.bodyMedium.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(icon, color: JuselColors.mutedForeground),
        ],
      ),
    );
  }
}

class _FilledInput extends StatelessWidget {
  final String hint;
  final TextInputType? keyboardType;
  final String? trailingText;

  const _FilledInput({
    required this.hint,
    this.keyboardType,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: trailingText != null ? 0 : 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: JuselTextStyles.bodyMedium.copyWith(
                  color: JuselColors.mutedForeground,
                ),
              ),
              style: JuselTextStyles.bodyMedium.copyWith(
                color: JuselColors.foreground,
              ),
            ),
          ),
          if (trailingText != null) ...[
            const SizedBox(width: 8),
            Text(
              trailingText!,
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
