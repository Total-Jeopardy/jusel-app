import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';
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
  String? _selectedProductId;
  _ProductOption? _selectedProduct;
  bool _initializedSelection = false;
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

  double get _previousCostPerUnit =>
      _selectedProduct?.product.currentCostPrice ?? 0.0;
  int get _previousStock => _selectedProduct?.stock ?? 0;
  bool _submitting = false;
  bool get _isFormValid =>
      _selectedProduct != null &&
      _totalUnitsAdding > 0 &&
      _totalCost > 0 &&
      _costPerUnit > 0;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.productId;
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(_restockProductsProvider);
    final newTotalStock = _previousStock + _totalUnitsAdding;

    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
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
              productsAsync.when(
                loading: () => const _ProductCard(),
                error: (e, _) => _ProductCard(
                  errorText: 'Failed to load products',
                ),
                data: (products) {
                  if (!_initializedSelection && products.isNotEmpty) {
                    final initialId =
                        _selectedProductId ?? widget.productId ?? '';
                    final selected = products.firstWhere(
                      (p) => p.product.id == initialId,
                      orElse: () => products.first,
                    );
                    _selectedProductId = selected.product.id;
                    _selectedProduct = selected;
                    _initializedSelection = true;
                  }
                  final summary = _selectedProduct == null
                      ? null
                      : _ProductSummary(
                          name: _selectedProduct!.product.name,
                          category: _selectedProduct!.product.category,
                          currentStock: _selectedProduct!.stock,
                          imageAsset: widget.imageAsset,
                        );
                  return _ProductCard(
                    product: summary,
                    onTap: products.isEmpty
                        ? null
                        : () async {
                            final choice = await showModalBottomSheet<String>(
                              context: context,
                              builder: (context) => _ProductPicker(
                                products: products,
                                selectedId: _selectedProductId,
                              ),
                            );
                            if (choice == null) return;
                            final selected = products.firstWhere(
                              (p) => p.product.id == choice,
                            );
                            setState(() {
                              _selectedProductId = choice;
                              _selectedProduct = selected;
                              // reset mode-specific fields when switching product
                              if (_mode == RestockMode.units) {
                                _unitsPerPackController.text = '1';
                              }
                            });
                          },
                  );
                },
              ),
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
              onPressed: _submitting || !_isFormValid ? null : _handleConfirm,
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
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Confirm Restock',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: JuselColors.destructive,
      ),
    );
  }

  String _friendlyError(Object error) {
    return error.toString().replaceFirst(RegExp(r'^Exception: '), '').trim();
  }

  Future<void> _handleConfirm() async {
    FocusScope.of(context).unfocus();

    if (_totalUnitsAdding <= 0 || _totalCost <= 0 || _costPerUnit <= 0) {
      _showError('Enter valid units and total cost to proceed');
      return;
    }

    final productId = _selectedProductId ?? widget.productId;
    if (productId == null || productId.isEmpty || _selectedProduct == null) {
      _showError('Missing product data for restock');
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final user = authState.valueOrNull;
    if (user == null) {
      _showError('Please log in to restock');
      return;
    }
    final userId = user.uid;
    final restockedByDisplay = user.name.trim().isNotEmpty ? user.name : 'User';
    final restockService = ref.read(restockServiceProvider);

    setState(() => _submitting = true);
    try {
      if (_mode == RestockMode.packs) {
        if (_packs <= 0) {
          _showError('Pack count must be greater than zero');
          return;
        }
        // Service expects packPrice (per pack); UI collects total cost.
        final packPrice = _totalCost / _packs;
        await restockService.restockFromPacks(
          productId: productId,
          packCount: _packs,
          packPrice: packPrice,
          createdByUserId: userId,
        );
      } else {
        await restockService.restockByUnits(
          productId: productId,
          units: _totalUnitsAdding,
          costPerUnit: _costPerUnit,
          createdByUserId: userId,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RestockSuccessScreen(
            productId: productId,
            productName: _selectedProduct!.product.name,
            category: _selectedProduct!.product.category,
            imageAsset: widget.imageAsset,
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
        _showError('Restock failed. ${_friendlyError(e)}');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _ProductCard extends StatelessWidget {
  final _ProductSummary? product;
  final VoidCallback? onTap;
  final String? errorText;

  const _ProductCard({this.product, this.onTap, this.errorText});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(JuselSpacing.s16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorText != null)
                      Text(
                        errorText!,
                        style: JuselTextStyles.bodyMedium.copyWith(
                          color: JuselColors.destructive,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else if (product == null)
                      Text(
                        'Select a product to restock',
                        style: JuselTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: JuselColors.foreground,
                        ),
                      )
                    else ...[
                      Text(
                        product!.name,
                        style: JuselTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: JuselColors.foreground,
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s4),
                      Text(
                        'Category: ${product!.category}',
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
                              'Current Stock: ${product!.currentStock} units',
                              style: JuselTextStyles.bodySmall.copyWith(
                                color: JuselColors.destructive,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _ProductPicker extends StatelessWidget {
  final List<_ProductOption> products;
  final String? selectedId;

  const _ProductPicker({
    required this.products,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: JuselColors.mutedForeground.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: JuselSpacing.s16,
              vertical: JuselSpacing.s8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Product',
                  style: JuselTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${products.length} total',
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = products[index];
                final selected = selectedId == item.product.id;
                return ListTile(
                  onTap: () => Navigator.pop(context, item.product.id),
                  title: Text(
                    item.product.name,
                    style: JuselTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Category: ${item.product.category} · Stock: ${item.stock}',
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: JuselColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check, color: JuselColors.primary)
                      : null,
                );
              },
            ),
          ),
        ],
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
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
  final List<TextInputFormatter>? inputFormatters;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.enabled = true,
    this.suffixIcon,
    this.textInputAction,
    this.onChanged,
    this.inputFormatters,
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
          inputFormatters: inputFormatters,
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
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
class _ProductOption {
  final ProductsTableData product;
  final int stock;

  const _ProductOption({required this.product, required this.stock});
}

final _restockProductsProvider =
    FutureProvider.autoDispose<List<_ProductOption>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final inventory = ref.read(inventoryServiceProvider);
  final products = await db.productsDao.getAllProducts();
  final stockMap = await inventory.getAllCurrentStock();
  final active = products.where((p) => p.status.toLowerCase() == 'active');
  return active
      .map(
        (p) => _ProductOption(
          product: p,
          stock: stockMap[p.id] ?? p.currentStockQty,
        ),
      )
      .toList();
});
