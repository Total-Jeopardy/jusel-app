import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';

class ProductSelectionModal extends ConsumerStatefulWidget {
  final ProductsTableData product;
  final Function(String productId, int quantity, double? overriddenPrice)?
  onAddToSale;

  const ProductSelectionModal({
    super.key,
    required this.product,
    this.onAddToSale,
  });

  @override
  ConsumerState<ProductSelectionModal> createState() =>
      _ProductSelectionModalState();

  static Future<void> show(
    BuildContext context, {
    required ProductsTableData product,
    Function(String productId, int quantity, double? overriddenPrice)?
    onAddToSale,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) =>
          ProductSelectionModal(product: product, onAddToSale: onAddToSale),
    );
  }
}

class _ProductSelectionModalState extends ConsumerState<ProductSelectionModal> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  int _quantity = 1;
  double? _overriddenPrice;
  bool _isPriceOverridden = false;
  bool _showPriceOverrideField = false;
  int? _currentStock;
  bool _isLoadingStock = true;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _priceController = TextEditingController(
      text: widget.product.currentSellingPrice.toStringAsFixed(2),
    );
    _loadCurrentStock();
  }

  Future<void> _loadCurrentStock() async {
    final inventoryService = ref.read(inventoryServiceProvider);
    final stock = await inventoryService.getCurrentStock(widget.product.id);
    if (mounted) {
      setState(() {
        _currentStock = stock;
        _isLoadingStock = false;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateQuantity(int delta) {
    final maxStock = _currentStock ?? widget.product.currentStockQty;
    final newQuantity = (_quantity + delta).clamp(1, maxStock);
    if (newQuantity != _quantity) {
      setState(() {
        _quantity = newQuantity;
        _quantityController.text = newQuantity.toString();
      });
    }
  }

  void _onQuantityChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _quantity = 0;
      });
      return;
    }

    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 0) {
      setState(() {
        _quantity = parsed;
      });
    }
  }

  void _togglePriceOverride() {
    setState(() {
      _showPriceOverrideField = !_showPriceOverrideField;
      if (!_showPriceOverrideField) {
        _isPriceOverridden = false;
        _overriddenPrice = null;
        _priceController.text = widget.product.currentSellingPrice
            .toStringAsFixed(2);
      }
    });
  }

  void _onPriceChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed > 0) {
      setState(() {
        _overriddenPrice = parsed;
        _isPriceOverridden = true;
      });
    } else if (value.isEmpty) {
      setState(() {
        _overriddenPrice = null;
        _isPriceOverridden = false;
      });
    }
  }

  void _handleAddToSale() {
    if (_quantity <= 0) {
      return;
    }

    final maxStock = _currentStock ?? widget.product.currentStockQty;
    if (_quantity > maxStock) {
      return;
    }

    final price = _isPriceOverridden && _overriddenPrice != null
        ? _overriddenPrice!
        : null;

    if (widget.onAddToSale != null) {
      widget.onAddToSale!(widget.product.id, _quantity, price);
    }

    Navigator.of(context).pop();
  }

  bool get _hasQuantityError {
    final maxStock = _currentStock ?? widget.product.currentStockQty;
    return _quantity > maxStock;
  }

  bool get _canAddToSale => _quantity > 0 && !_hasQuantityError;

  @override
  Widget build(BuildContext context) {
    final availableStock = _currentStock ?? widget.product.currentStockQty;
    final unitPrice = _isPriceOverridden && _overriddenPrice != null
        ? _overriddenPrice!
        : widget.product.currentSellingPrice;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: JuselTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: JuselColors.mutedForeground,
                  ),
                ],
              ),
            ),

            // Stock Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isLoadingStock
                  ? const SizedBox(
                      height: 28,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: JuselColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$availableStock in stock',
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: JuselColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: JuselSpacing.s20),

            // Price and Quantity Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unit Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UNIT PRICE',
                              style: JuselTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: JuselColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (!_showPriceOverrideField)
                              Text(
                                'GHS ${unitPrice.toStringAsFixed(2)}',
                                style: JuselTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            else
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: _priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                  onChanged: _onPriceChanged,
                                  style: JuselTextStyles.headlineMedium
                                      .copyWith(fontWeight: FontWeight.w700),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: JuselColors.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: JuselColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: JuselColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _togglePriceOverride,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Override',
                                    style: JuselTextStyles.bodySmall.copyWith(
                                      color: JuselColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _showPriceOverrideField
                                        ? Icons.check
                                        : Icons.edit,
                                    size: 14,
                                    color: JuselColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _hasQuantityError
                                ? JuselColors.destructive
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Minus Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _quantity > 1
                                    ? () => _updateQuantity(-1)
                                    : null,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: _quantity <= 1
                                        ? JuselColors.mutedForeground
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ),

                            // Quantity Input
                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              color: Colors.white,
                              child: TextField(
                                controller: _quantityController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: _onQuantityChanged,
                                style: JuselTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),

                            // Plus Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: !_hasQuantityError
                                    ? () => _updateQuantity(1)
                                    : null,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: _hasQuantityError
                                        ? JuselColors.mutedForeground
                                        : JuselColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Error Message
            if (_hasQuantityError && !_isLoadingStock) ...[
              const SizedBox(height: JuselSpacing.s12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 18,
                      color: JuselColors.destructive,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Quantity exceeds available stock ($availableStock).',
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: JuselColors.destructive,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: JuselSpacing.s24),

            // Add to Sale Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Material(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _canAddToSale ? _handleAddToSale : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      'Add to Sale',
                      style: JuselTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _canAddToSale
                            ? JuselColors.foreground
                            : JuselColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
