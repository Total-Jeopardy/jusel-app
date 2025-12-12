import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';

class ProductSelectionModal extends ConsumerStatefulWidget {
  final ProductsTableData product;
  final Function(
    String productId,
    int quantity,
    double? overriddenPrice,
    String? overrideReason,
  )?
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
    Function(
      String productId,
      int quantity,
      double? overriddenPrice,
      String? overrideReason,
    )?
    onAddToSale,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          ProductSelectionModal(product: product, onAddToSale: onAddToSale),
    );
  }
}

class _ProductSelectionModalState extends ConsumerState<ProductSelectionModal> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _overrideReasonController;
  int _quantity = 1;
  double? _overriddenPrice;
  bool _isPriceOverridden = false;
  bool _showPriceOverrideField = false;
  int? _currentStock;
  bool _isLoadingStock = true;
  String? _selectedOverrideReason;
  final List<String> _overrideReasons = const [
    'Customer discount',
    'Customer cash was short',
    'Complimentary / free sale',
    'Price match / competitor',
    'Damaged packaging',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _priceController = TextEditingController(
      text: widget.product.currentSellingPrice.toStringAsFixed(2),
    );
    _overrideReasonController = TextEditingController();
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
    _overrideReasonController.dispose();
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
        _selectedOverrideReason = null;
        _overrideReasonController.clear();
      } else {
        _isPriceOverridden = true;
        _overriddenPrice =
            double.tryParse(_priceController.text) ??
            widget.product.currentSellingPrice;
      }
    });
  }

  void _onPriceChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 0) {
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

  void _onOverrideReasonSelected(String reason) {
    setState(() {
      _selectedOverrideReason = reason;
      if (reason != 'Other') {
        _overrideReasonController.clear();
      }
    });
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
    final reason = _resolvedOverrideReason;

    if (widget.onAddToSale != null) {
      widget.onAddToSale!(widget.product.id, _quantity, price, reason);
    }

    Navigator.of(context).pop();
  }

  bool get _hasQuantityError {
    final maxStock = _currentStock ?? widget.product.currentStockQty;
    return _quantity > maxStock;
  }

  bool get _requiresOverrideReason => _showPriceOverrideField;

  bool get _hasValidOverrideReason {
    if (!_requiresOverrideReason) return true;
    if (_selectedOverrideReason == null) return false;
    if (_selectedOverrideReason == 'Other') {
      return _overrideReasonController.text.trim().isNotEmpty;
    }
    return true;
  }

  String? get _resolvedOverrideReason {
    if (!_requiresOverrideReason) return null;
    if (_selectedOverrideReason == null) return null;
    if (_selectedOverrideReason == 'Other') {
      final text = _overrideReasonController.text.trim();
      return text.isEmpty ? null : text;
    }
    return _selectedOverrideReason;
  }

  bool get _hasValidPriceOverride =>
      !_showPriceOverrideField || _overriddenPrice != null;

  bool get _canAddToSale =>
      _quantity > 0 &&
      !_hasQuantityError &&
      _hasValidOverrideReason &&
      _hasValidPriceOverride;

  @override
  Widget build(BuildContext context) {
    final availableStock = _currentStock ?? widget.product.currentStockQty;
    final unitPrice = _isPriceOverridden && _overriddenPrice != null
        ? _overriddenPrice!
        : widget.product.currentSellingPrice;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: JuselColors.card(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: JuselTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 23,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: JuselColors.mutedForeground(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _isLoadingStock
                          ? const SizedBox(
                              height: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: JuselColors.successColor(context).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$availableStock in stock',
                                style: JuselTextStyles.bodyMedium(context).copyWith(
                                  color: JuselColors.successColor(context),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(JuselSpacing.s16),
                      decoration: BoxDecoration(
                        color: JuselColors.muted(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: JuselColors.border(context)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'UNIT PRICE',
                                      style: JuselTextStyles.bodySmall(context).copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: JuselColors.mutedForeground(context),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (!_showPriceOverrideField)
                                      Text(
                                        'GHS ${unitPrice.toStringAsFixed(2)}',
                                        style: JuselTextStyles.headlineMedium(context)
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      )
                                    else
                                      SizedBox(
                                        width: 140,
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
                                          style: JuselTextStyles.headlineMedium(context)
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            filled: true,
                                            fillColor: JuselColors.card(context),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                            errorText:
                                                _showPriceOverrideField &&
                                                    _overriddenPrice == null
                                                ? 'Enter a valid amount (0 allowed)'
                                                : null,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: JuselColors.border(context),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: JuselColors.border(context),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: JuselColors.primaryColor(context),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    if (_showPriceOverrideField) ...[
                                      Text(
                                        'Why override price?',
                                        style: JuselTextStyles.bodySmall(context)
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  JuselColors.mutedForeground(context),
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _overrideReasons
                                            .map(
                                              (reason) => ChoiceChip(
                                                label: Text(reason),
                                                selected:
                                                    _selectedOverrideReason ==
                                                    reason,
                                                onSelected: (_) =>
                                                    _onOverrideReasonSelected(
                                                      reason,
                                                    ),
                                                labelStyle: JuselTextStyles
                                                    .bodySmall(context)
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          _selectedOverrideReason ==
                                                              reason
                                                          ? JuselColors
                                                                .primaryForeground
                                                          : JuselColors
                                                                .foreground(context),
                                                    ),
                                                selectedColor:
                                                    JuselColors.primaryColor(context),
                                                backgroundColor: JuselColors.card(context),
                                                side: BorderSide(
                                                  color: JuselColors.border(context),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      if (_selectedOverrideReason ==
                                          'Other') ...[
                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: _overrideReasonController,
                                          maxLines: 3,
                                          onChanged: (_) => setState(() {}),
                                          decoration: InputDecoration(
                                            labelText:
                                                'Add a short note for audit trail',
                                            filled: true,
                                            fillColor: JuselColors.card(context),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: JuselColors.border(context),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: JuselColors.border(context),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: JuselColors.primaryColor(context),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          style: JuselTextStyles.bodyMedium(context)
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                      if (_requiresOverrideReason &&
                                          !_hasValidOverrideReason)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: JuselSpacing.s8,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: JuselColors.destructiveColor(context),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Select a reason before adding to sale.',
                                                  style: JuselTextStyles
                                                      .bodySmall(context)
                                                      .copyWith(
                                                        color: JuselColors
                                                            .destructiveColor(context),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                    ],
                                    GestureDetector(
                                      onTap: _togglePriceOverride,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Override',
                                            style: JuselTextStyles.bodySmall(context)
                                                .copyWith(
                                                  color: JuselColors.primaryColor(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            _showPriceOverrideField
                                                ? Icons.check
                                                : Icons.edit,
                                            size: 14,
                                            color: JuselColors.primaryColor(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: JuselColors.card(context),
                                  border: Border.all(
                                    color: _hasQuantityError
                                        ? JuselColors.destructiveColor(context)
                                        : JuselColors.border(context),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _quantity > 1
                                            ? () => _updateQuantity(-1)
                                            : null,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
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
                                                ? JuselColors.mutedForeground(context)
                                                : JuselColors.destructiveColor(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      color: JuselColors.card(context),
                                      child: TextField(
                                        controller: _quantityController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        onChanged: _onQuantityChanged,
                                        style: JuselTextStyles.bodyMedium(context)
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: !_hasQuantityError
                                            ? () => _updateQuantity(1)
                                            : null,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
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
                                                ? JuselColors.mutedForeground(context)
                                                : JuselColors.primaryColor(context),
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
                    if (_hasQuantityError && !_isLoadingStock) ...[
                      const SizedBox(height: JuselSpacing.s12),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(JuselSpacing.s12),
                        decoration: BoxDecoration(
                          color: JuselColors.destructiveColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: JuselColors.destructiveColor(context).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 18,
                              color: JuselColors.destructiveColor(context),
                            ),
                            const SizedBox(width: JuselSpacing.s8),
                            Expanded(
                              child: Text(
                                'Quantity exceeds available stock ($availableStock).',
                                style: JuselTextStyles.bodySmall(context).copyWith(
                                  color: JuselColors.destructiveColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: JuselSpacing.s24),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom + 12
                    : 20,
              ),
              decoration: BoxDecoration(
                color: JuselColors.card(context),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canAddToSale ? _handleAddToSale : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JuselColors.primaryColor(context),
                    foregroundColor: JuselColors.primaryForeground,
                    disabledBackgroundColor: JuselColors.muted(context),
                    disabledForegroundColor: JuselColors.mutedForeground(context),
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add to Sale',
                    style: JuselTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: _canAddToSale
                          ? JuselColors.primaryForeground
                          : JuselColors.mutedForeground(context),
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
