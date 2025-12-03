import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/stock/view/restock_success_screen.dart';

class RestockScreen extends ConsumerStatefulWidget {
  final String? productId;
  final String? productName;
  final String? category;
  final int? currentStock;
  final String? imageAsset;

  const RestockScreen({
    super.key,
    this.productId,
    this.productName,
    this.category,
    this.currentStock,
    this.imageAsset,
  });

  @override
  ConsumerState<RestockScreen> createState() => _RestockScreenState();
}

class _RestockScreenState extends ConsumerState<RestockScreen> {
  // Placeholder product for now; hook up to real selection later.
  late final _ProductSummary _product = _ProductSummary(
    name: widget.productName ?? 'Cola 500ml',
    category: widget.category ?? 'Drinks',
    currentStock: widget.currentStock ?? 4,
    imageAsset: widget.imageAsset,
  );
  final TextEditingController _packsController = TextEditingController(
    text: '5',
  );
  final TextEditingController _unitsPerPackController = TextEditingController(
    text: '12',
  );
  final TextEditingController _totalCostController = TextEditingController(
    text: '30.00',
  );

  RestockMode _mode = RestockMode.packs;
  static const int _reorderThreshold = 10;

  int get _packs {
    final value = int.tryParse(_packsController.text.trim()) ?? 0;
    return math.max(0, value);
  }

  int get _unitsPerPack {
    final value = int.tryParse(_unitsPerPackController.text.trim()) ?? 0;
    return math.max(0, value);
  }

  int get _totalUnitsAdding =>
      _mode == RestockMode.packs ? _packs * _unitsPerPack : _packs;

  double get _totalCost =>
      double.tryParse(_totalCostController.text.trim()) ?? 0.0;

  double get _costPerUnit =>
      _totalUnitsAdding > 0 ? _totalCost / _totalUnitsAdding : 0.0;

  static const double _previousCostPerUnit = 0.45;
  int get _previousStock => _product.currentStock;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final newTotalStock = _previousStock + _totalUnitsAdding;

    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Restock',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: JuselSpacing.s16),
              Text(
                'Product',
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: JuselColors.mutedForeground,
                ),
              ),
              const SizedBox(height: JuselSpacing.s12),
              _ProductCard(product: _product),
              const SizedBox(height: JuselSpacing.s24),
              Text(
                'Restock Mode',
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: JuselColors.mutedForeground,
                ),
              ),
              const SizedBox(height: JuselSpacing.s12),
              _RestockModeCard(
                mode: _mode,
                onModeChanged: (mode) {
                  setState(() {
                    _mode = mode;
                    if (_mode == RestockMode.units) {
                      _unitsPerPackController.text = '1';
                    }
                  });
                },
                packsController: _packsController,
                unitsPerPackController: _unitsPerPackController,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: JuselSpacing.s24),
              _TotalCostCard(
                totalUnits: _totalUnitsAdding,
                totalCostController: _totalCostController,
                costPerUnit: _costPerUnit,
                previousCostPerUnit: _previousCostPerUnit,
                onCostChanged: () => setState(() {}),
              ),
              const SizedBox(height: JuselSpacing.s24),
              _ImpactSummaryCard(
                previousStock: _previousStock,
                addingUnits: _totalUnitsAdding,
                newTotalStock: newTotalStock,
                totalInventoryValue: _totalCost,
                reorderThreshold: _reorderThreshold,
                costPerUnit: _costPerUnit,
                previousCostPerUnit: _previousCostPerUnit,
              ),
              const SizedBox(height: JuselSpacing.s20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JuselColors.primary,
                    foregroundColor: JuselColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Restock',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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

  @override
  void dispose() {
    _packsController.dispose();
    _unitsPerPackController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_totalUnitsAdding <= 0 || _totalCost <= 0 || _costPerUnit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid units and total cost to proceed'),
          backgroundColor: JuselColors.destructive,
        ),
      );
      return;
    }

    final productId = widget.productId;
    if (productId == null || productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing product data for restock'),
          backgroundColor: JuselColors.destructive,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to restock'),
          backgroundColor: JuselColors.destructive,
        ),
      );
      return;
    }
    final userId = user.uid;
    final restockedByDisplay = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : 'User';
    final restockService = ref.read(restockServiceProvider);

    setState(() => _submitting = true);
    try {
      await restockService.restockByUnits(
        productId: productId,
        units: _totalUnitsAdding,
        costPerUnit: _costPerUnit,
        createdByUserId: userId,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RestockSuccessScreen(
            productName: _product.name,
            category: _product.category,
            imageAsset: _product.imageAsset,
            unitsAdded: _totalUnitsAdding,
            newTotalStock: _previousStock + _totalUnitsAdding,
            costPerUnit: _costPerUnit,
            inventoryValueAdded: _totalCost,
            restockedBy: restockedByDisplay,
            restockedOn: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restock failed: $e'),
            backgroundColor: JuselColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _ProductCard extends StatelessWidget {
  final _ProductSummary product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // TODO: open product selection modal
        },
        child: Padding(
          padding: const EdgeInsets.all(JuselSpacing.s16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: JuselTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s4),
                    Text(
                      'Category: ${product.category}',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: JuselColors.destructive,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Current Stock: ${product.currentStock} units',
                            style: JuselTextStyles.bodySmall.copyWith(
                              color: JuselColors.destructive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: JuselColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestockModeCard extends StatelessWidget {
  final RestockMode mode;
  final ValueChanged<RestockMode> onModeChanged;
  final TextEditingController packsController;
  final TextEditingController unitsPerPackController;
  final VoidCallback onChanged;

  const _RestockModeCard({
    required this.mode,
    required this.onModeChanged,
    required this.packsController,
    required this.unitsPerPackController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPacks = mode == RestockMode.packs;
    final leadingLabel = isPacks ? 'Number of Packs' : 'Units';
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _ModeChip(
                    label: 'By Packs',
                    isActive: isPacks,
                    onTap: () => onModeChanged(RestockMode.packs),
                  ),
                  _ModeChip(
                    label: 'By Units',
                    isActive: !isPacks,
                    onTap: () => onModeChanged(RestockMode.units),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: leadingLabel,
                    controller: packsController,
                    enabled: true,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: JuselSpacing.s12),
                Expanded(
                  child: _LabeledField(
                    label: 'Units per Pack',
                    controller: unitsPerPackController,
                    enabled: isPacks,
                    suffixIcon: const Icon(Icons.edit, size: 18),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x1A1F6BFF),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: JuselTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isActive
                  ? JuselColors.primary
                  : JuselColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.enabled = true,
    this.suffixIcon,
    this.textInputAction,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: JuselTextStyles.bodySmall.copyWith(
            color: JuselColors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: JuselSpacing.s6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textInputAction: textInputAction,
          onChanged: onChanged,
          decoration: InputDecoration(
            suffixIcon: suffixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: suffixIcon,
                  ),
            suffixIconConstraints: const BoxConstraints(
              minHeight: 32,
              minWidth: 32,
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalCostCard extends StatelessWidget {
  final int totalUnits;
  final TextEditingController totalCostController;
  final double costPerUnit;
  final double previousCostPerUnit;
  final VoidCallback onCostChanged;

  const _TotalCostCard({
    required this.totalUnits,
    required this.totalCostController,
    required this.costPerUnit,
    required this.previousCostPerUnit,
    required this.onCostChanged,
  });

  @override
  Widget build(BuildContext context) {
    final delta = previousCostPerUnit == 0
        ? 0.0
        : ((costPerUnit - previousCostPerUnit) / previousCostPerUnit) * 100;
    final deltaPrefix = delta >= 0 ? '+' : '';
    final deltaColor = delta >= 0
        ? JuselColors.destructive
        : JuselColors.success;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: JuselSpacing.s12,
                vertical: JuselSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Units Adding',
                    style: JuselTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: JuselColors.mutedForeground,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+$totalUnits',
                        style: JuselTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: JuselColors.primary,
                        ),
                      ),
                      Text(
                        'Units',
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: JuselColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            Text(
              'Total Cost (GHS)',
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: JuselSpacing.s6),
            TextField(
              controller: totalCostController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => onCostChanged(),
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: JuselSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calculate_outlined,
                      size: 18,
                      color: JuselColors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cost per Unit',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  'GHS ${costPerUnit.toStringAsFixed(2)}',
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history,
                      size: 18,
                      color: JuselColors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Previous Cost',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'GHS ${previousCostPerUnit.toStringAsFixed(2)}',
                      style: JuselTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: JuselColors.foreground,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$deltaPrefix${delta.toStringAsFixed(0)}%',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: deltaColor,
                        fontWeight: FontWeight.w700,
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

enum RestockMode { packs, units }

class _ImpactSummaryCard extends StatelessWidget {
  final int previousStock;
  final int addingUnits;
  final int newTotalStock;
  final double totalInventoryValue;
  final int reorderThreshold;
  final double costPerUnit;
  final double previousCostPerUnit;

  const _ImpactSummaryCard({
    required this.previousStock,
    required this.addingUnits,
    required this.newTotalStock,
    required this.totalInventoryValue,
    required this.reorderThreshold,
    required this.costPerUnit,
    required this.previousCostPerUnit,
  });

  @override
  Widget build(BuildContext context) {
    final willBeAboveThreshold = newTotalStock >= reorderThreshold;
    final costDelta = previousCostPerUnit == 0
        ? 0.0
        : ((costPerUnit - previousCostPerUnit) / previousCostPerUnit) * 100;
    final isCostHigher = costDelta >= 0;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact Summary',
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Previous Stock',
                  style: JuselTextStyles.bodyMedium.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$previousStock units',
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adding',
                  style: JuselTextStyles.bodyMedium.copyWith(
                    color: JuselColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '+$addingUnits units',
                  style: JuselTextStyles.bodyMedium.copyWith(
                    color: JuselColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s12),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: JuselSpacing.s12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Total Stock',
                      style: JuselTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s6),
                    Text(
                      'Total inventory value: +GHS ${totalInventoryValue.toStringAsFixed(2)}',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$newTotalStock',
                      style: JuselTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: JuselColors.foreground,
                      ),
                    ),
                    Text(
                      'units',
                      style: JuselTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s16),
            if (willBeAboveThreshold)
              _InfoBanner(
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF16A34A),
                backgroundColor: const Color(0xFFE9F8EF),
                text:
                    'Stock will be above reorder threshold ($reorderThreshold).',
                textColor: const Color(0xFF15803D),
              ),
            if (willBeAboveThreshold) const SizedBox(height: JuselSpacing.s8),
            _InfoBanner(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFF59E0B),
              backgroundColor: const Color(0xFFFFF7E6),
              borderColor: const Color(0xFFFDE68A),
              text:
                  'Margin Alert: New unit cost (GHS ${costPerUnit.toStringAsFixed(2)}) is ${isCostHigher ? 'higher' : 'lower'} than previous average (GHS ${previousCostPerUnit.toStringAsFixed(2)}).',
              textColor: const Color(0xFF92400E),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color? borderColor;
  final String text;
  final Color textColor;

  const _InfoBanner({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.text,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: JuselSpacing.s8),
          Expanded(
            child: Text(
              text,
              style: JuselTextStyles.bodySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSummary {
  final String name;
  final String category;
  final int currentStock;
  final String? imageAsset;

  const _ProductSummary({
    required this.name,
    required this.category,
    required this.currentStock,
    this.imageAsset,
  });
}
