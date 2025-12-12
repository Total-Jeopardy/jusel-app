import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/account/view/account_screen.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_tab_provider.dart';
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            ref.read(dashboardTabProvider.notifier).goToDashboard();
          }
        }
      },
      child: Scaffold(
        backgroundColor: JuselColors.background(context),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                ref.read(dashboardTabProvider.notifier).goToDashboard();
              }
            },
        ),
        title: const Text(
          'Restock',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: JuselSpacing.s12),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: JuselColors.muted(context),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: JuselColors.mutedForeground(context),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(height: 1, color: JuselColors.border(context)),
              const SizedBox(height: JuselSpacing.s16),
              Text(
                'Product',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: JuselColors.mutedForeground(context),
                ),
              ),
              const SizedBox(height: JuselSpacing.s12),
              productsAsync.when(
                loading: () => const _ProductCard(),
                error: (e, _) =>
                    const _ProductCard(errorText: 'Failed to load products'),
                data: (products) {
                  // Provider already filters to isProduced == false, so use directly
                  // Double-check: ensure no produced items slipped through
                  final eligibleProducts = products
                      .where((p) => p.product.isProduced == false)
                      .toList();

                  if (!_initializedSelection) {
                    final explicitId = _selectedProductId ?? widget.productId;
                    if (explicitId != null && explicitId.isNotEmpty) {
                      final match = eligibleProducts
                          .where((p) => p.product.id == explicitId)
                          .toList();
                      if (match.isNotEmpty) {
                        _selectedProductId = match.first.product.id;
                        _selectedProduct = match.first;
                      } else {
                        // Product ID was provided but not found in eligible products
                        // Check if it's a produced product
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          final db = ref.read(appDatabaseProvider);
                          final product = await db.productsDao.getProduct(
                            explicitId,
                          );
                          if (product != null && product.isProduced == true) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'This product is locally produced. Please use "Add Batch" instead of Restock.',
                                      ),
                                      backgroundColor: JuselColors.warningColor(context),
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        });
                        // Clear the invalid selection
                        _selectedProductId = null;
                        _selectedProduct = null;
                      }
                    }
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
                    onTap: eligibleProducts.isEmpty
                        ? null
                        : () async {
                            final choice = await showModalBottomSheet<String>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => _ProductPicker(
                                products: eligibleProducts,
                                selectedId: _selectedProductId,
                              ),
                            );
                            if (choice == null) return;
                            final selected = eligibleProducts.firstWhere(
                              (p) => p.product.id == choice,
                            );
                            // Final safety check (should never be true if provider works correctly)
                            if (selected.product.isProduced == true) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'This product is locally produced. Please use "Add Batch" instead of Restock.',
                                    ),
                                    backgroundColor: JuselColors.warningColor(context),
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              }
                              return;
                            }
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
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: JuselColors.mutedForeground(context),
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
                  onPressed: _submitting || !_isFormValid
                      ? null
                      : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JuselColors.primaryColor(context),
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
                              JuselColors.primaryForeground,
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
        backgroundColor: JuselColors.destructiveColor(context),
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

      // Invalidate dashboard to refresh metrics/low stock
      ref.invalidate(dashboardProvider);

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
    // Use GestureDetector for reliable touch handling on physical devices
    // Wrap with Material + InkWell for visual feedback
    return GestureDetector(
      // Explicitly set behavior to ensure entire area is tappable
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: JuselColors.card(context),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            // Explicitly set splash and highlight colors for better feedback
            splashColor: JuselColors.primaryColor(context).withOpacity(0.1),
            highlightColor: JuselColors.primaryColor(context).withOpacity(0.05),
            // Ensure the entire area is tappable
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
                          style: JuselTextStyles.bodyMedium(context).copyWith(
                            color: JuselColors.destructiveColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else if (product == null)
                        Text(
                          'Select a product to restock',
                          style: JuselTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: JuselColors.foreground(context),
                          ),
                        )
                      else ...[
                        Text(
                          product!.name,
                          style: JuselTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: JuselColors.foreground(context),
                          ),
                        ),
                        const SizedBox(height: JuselSpacing.s4),
                        Text(
                          'Category: ${product!.category}',
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                          ),
                        ),
                        const SizedBox(height: JuselSpacing.s12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: JuselColors.destructiveColor(context).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: JuselColors.destructiveColor(context),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Current Stock: ${product!.currentStock} units',
                                style: JuselTextStyles.bodySmall(context).copyWith(
                                  color: JuselColors.destructiveColor(context),
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
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: JuselColors.mutedForeground(context),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _ProductPicker extends StatefulWidget {
  final List<_ProductOption> products;
  final String? selectedId;

  const _ProductPicker({required this.products, required this.selectedId});

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  Timer? _debounceTimer;
  Map<String, List<_ProductOption>>? _cachedGrouped;
  String? _cachedQuery;
  _PickerFilter _activeFilter = const _PickerFilter.all();
  static const int _lowStockThreshold = 5;

  // Safety: Ensure only non-produced products are shown
  List<_ProductOption> get _safeProducts =>
      widget.products.where((p) => p.product.isProduced == false).toList();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _searchQuery = value.toLowerCase().trim();
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _cachedGrouped = null;
      _cachedQuery = null;
      _activeFilter = const _PickerFilter.all();
    });
  }

  List<_ProductOption> _filterProducts(List<_ProductOption> products) {
    if (_searchQuery.isEmpty) return products;
    return products.where((option) {
      final name = option.product.name.toLowerCase();
      final category = option.product.category.toLowerCase();
      return name.contains(_searchQuery) || category.contains(_searchQuery);
    }).toList();
  }

  Map<String, List<_ProductOption>> _groupByCategory(
    List<_ProductOption> products,
  ) {
    final grouped = <String, List<_ProductOption>>{};
    for (final option in products) {
      final category = option.product.category;
      grouped.putIfAbsent(category, () => []).add(option);
    }
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(sortedEntries);
  }

  Map<String, List<_ProductOption>> get _groupedProducts {
    if (_cachedQuery == _searchQuery && _cachedGrouped != null) {
      return _cachedGrouped!;
    }
    final filtered = _applyFilters(_filterProducts(_safeProducts));
    _cachedGrouped = _groupByCategory(filtered);
    _cachedQuery = _searchQuery;
    return _cachedGrouped!;
  }

  int get _filteredCount =>
      _applyFilters(_filterProducts(_safeProducts)).length;

  List<_PickerFilter> get _filters {
    final categories =
        _safeProducts.map((p) => p.product.category).toSet().toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final categoryFilters = categories
        .map((c) => _PickerFilter.category(c))
        .toList();
    final filters = <_PickerFilter>[
      const _PickerFilter.all(),
      const _PickerFilter.lowStock(),
      const _PickerFilter.recent(),
    ];
    filters.addAll(categoryFilters);
    return filters;
  }

  List<_ProductOption> _applyFilters(List<_ProductOption> products) {
    switch (_activeFilter.type) {
      case _PickerFilterType.all:
        return products;
      case _PickerFilterType.category:
        final cat = _activeFilter.value?.toLowerCase() ?? '';
        return products
            .where((p) => (p.product.category.toLowerCase() == cat))
            .toList();
      case _PickerFilterType.lowStock:
        return products.where((p) => p.stock <= _lowStockThreshold).toList();
      case _PickerFilterType.recent:
        if (widget.selectedId == null || widget.selectedId!.isEmpty) {
          return <_ProductOption>[];
        }
        return products
            .where((p) => p.product.id == widget.selectedId)
            .toList();
    }
  }

  int _getTotalItemCount(Map<String, List<_ProductOption>> grouped) {
    var count = 0;
    for (final entry in grouped.entries) {
      count += 1; // header
      count += entry.value.length;
    }
    return count;
  }

  Widget _buildGroupedItem(
    Map<String, List<_ProductOption>> grouped,
    int index,
  ) {
    var currentIndex = 0;
    for (final entry in grouped.entries) {
      final category = entry.key;
      final items = entry.value;
      if (index == currentIndex) {
        return _CategoryHeader(category: category);
      }
      currentIndex += 1;
      for (final item in items) {
        if (index == currentIndex) {
          final selected = widget.selectedId == item.product.id;
          return _ProductPickerItem(
            option: item,
            selected: selected,
            onTap: () => Navigator.pop(context, item.product.id),
          );
        }
        currentIndex += 1;
      }
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    final grouped = _groupedProducts;
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
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
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Product',
                          style: JuselTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: JuselColors.muted(context).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _searchQuery.isEmpty
                                ? '${_safeProducts.length} products'
                                : '$_filteredCount results',
                            style: JuselTextStyles.bodySmall(context).copyWith(
                              color: JuselColors.mutedForeground(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: _clearSearch,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      : null,
                  filled: true,
                  fillColor: JuselColors.muted(context),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: JuselColors.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: JuselColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: JuselColors.primaryColor(context),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: _filters
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter.label),
                          selected: _activeFilter == filter,
                          onSelected: (_) => setState(() {
                            _activeFilter = filter;
                            _cachedGrouped = null;
                            _cachedQuery = null;
                          }),
                          labelStyle: JuselTextStyles.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: _activeFilter == filter
                                ? JuselColors.primaryForeground
                                : JuselColors.foreground(context),
                          ),
                          selectedColor: JuselColors.primaryColor(context),
                          backgroundColor: JuselColors.card(context),
                          side: BorderSide(color: JuselColors.border(context)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (_safeProducts.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(JuselSpacing.s24),
                    child: Text(
                      'No products available',
                      style: JuselTextStyles.bodyMedium(context),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: grouped.isEmpty
                    ? _EmptySearchState(
                        query: _searchQuery,
                        onClear: _clearSearch,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: JuselSpacing.s20,
                        ),
                        itemCount: _getTotalItemCount(grouped),
                        itemBuilder: (context, index) =>
                            _buildGroupedItem(grouped, index),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductPickerItem extends StatelessWidget {
  final _ProductOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ProductPickerItem({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highlightColor = JuselColors.primaryColor(context).withOpacity(0.08);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: selected ? highlightColor : JuselColors.card(context),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(JuselSpacing.s16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? JuselColors.primaryColor(context) : JuselColors.border(context),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.product.name,
                        style: JuselTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s4),
                      Text(
                        'Category: ${option.product.category}',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: JuselColors.successColor(context).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${option.stock} in stock',
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.successColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: JuselSpacing.s12),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: selected ? JuselColors.primaryColor(context) : JuselColors.muted(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected ? Icons.check : Icons.chevron_right,
                    size: 16,
                    color: selected
                        ? JuselColors.primaryForeground
                        : JuselColors.mutedForeground(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String category;

  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: JuselColors.muted(context).withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: JuselColors.border(context).withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Text(
        category,
        style: JuselTextStyles.bodyMedium(context).copyWith(
          fontWeight: FontWeight.w700,
          color: JuselColors.foreground(context),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _EmptySearchState({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: JuselColors.mutedForeground(context).withOpacity(0.5),
            ),
            const SizedBox(height: JuselSpacing.s16),
            Text(
              'No results for "$query"',
              style: JuselTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w700,
                color: JuselColors.foreground(context),
              ),
            ),
            const SizedBox(height: JuselSpacing.s8),
            Text(
              'Try a different search term',
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            TextButton(
              onPressed: onClear,
              child: Text(
                'Clear search',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  color: JuselColors.primaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PickerFilterType { all, category, lowStock, recent }

class _PickerFilter {
  final String label;
  final _PickerFilterType type;
  final String? value;

  const _PickerFilter._(this.label, this.type, [this.value]);

  const _PickerFilter.all() : this._('All', _PickerFilterType.all);

  const _PickerFilter.lowStock()
    : this._('Low stock', _PickerFilterType.lowStock);

  const _PickerFilter.recent()
    : this._('Recently accessed', _PickerFilterType.recent);

  const _PickerFilter.category(String category)
    : this._(category, _PickerFilterType.category, category);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PickerFilter &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => Object.hash(label, type, value);
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
                color: JuselColors.primaryColor(context).withOpacity(0.08),
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            color: isActive ? JuselColors.card(context) : Colors.transparent,
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
            style: JuselTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w700,
              color: isActive
                  ? JuselColors.primaryColor(context)
                  : JuselColors.mutedForeground(context),
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
          style: JuselTextStyles.bodySmall(context).copyWith(
            color: JuselColors.mutedForeground(context),
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
        ? JuselColors.destructiveColor(context)
        : JuselColors.successColor(context);

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
                color: JuselColors.primaryColor(context).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Units Adding',
                    style: JuselTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: JuselColors.mutedForeground(context),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+$totalUnits',
                        style: JuselTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w800,
                          color: JuselColors.primaryColor(context),
                        ),
                      ),
                      Text(
                        'Units',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
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
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
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
                    Icon(
                      Icons.calculate_outlined,
                      size: 18,
                      color: JuselColors.mutedForeground(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cost per Unit',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  'GHS ${costPerUnit.toStringAsFixed(2)}',
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground(context),
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
                    Icon(
                      Icons.history,
                      size: 18,
                      color: JuselColors.mutedForeground(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Previous Cost',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'GHS ${previousCostPerUnit.toStringAsFixed(2)}',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: JuselColors.foreground(context),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$deltaPrefix${delta.toStringAsFixed(0)}%',
                      style: JuselTextStyles.bodySmall(context).copyWith(
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
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Previous Stock',
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$previousStock units',
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground(context),
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
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    color: JuselColors.primaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '+$addingUnits units',
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    color: JuselColors.primaryColor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s12),
            Divider(height: 1, color: JuselColors.border(context)),
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
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground(context),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s6),
                    Text(
                      'Total inventory value: +GHS ${totalInventoryValue.toStringAsFixed(2)}',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$newTotalStock',
                      style: JuselTextStyles.headlineLarge(context).copyWith(
                        fontWeight: FontWeight.w800,
                        color: JuselColors.foreground(context),
                      ),
                    ),
                    Text(
                      'units',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground(context),
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
                iconColor: JuselColors.successColor(context),
                backgroundColor: JuselColors.successColor(context).withOpacity(0.12),
                text:
                    'Stock will be above reorder threshold ($reorderThreshold).',
                textColor: JuselColors.successColor(context),
              ),
            if (willBeAboveThreshold) const SizedBox(height: JuselSpacing.s8),
            _InfoBanner(
              icon: Icons.warning_amber_rounded,
              iconColor: JuselColors.warningColor(context),
              backgroundColor: JuselColors.warningColor(context).withOpacity(0.15),
              borderColor: JuselColors.warningColor(context).withOpacity(0.3),
              text:
                  'Margin Alert: New unit cost (GHS ${costPerUnit.toStringAsFixed(2)}) is ${isCostHigher ? 'higher' : 'lower'} than previous average (GHS ${previousCostPerUnit.toStringAsFixed(2)}).',
              textColor: JuselColors.warningColor(context),
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
              style: JuselTextStyles.bodySmall(context).copyWith(
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

final _restockProductsProvider = FutureProvider.autoDispose<List<_ProductOption>>((
  ref,
) async {
  final db = ref.read(appDatabaseProvider);
  final inventory = ref.read(inventoryServiceProvider);
  final products = await db.productsDao.getAllProducts();
  final stockMap = await inventory.getAllCurrentStock();
  // Only include active, non-produced products (produced items use Production Batches)
  final eligible = products.where(
    (p) => p.status.toLowerCase() == 'active' && p.isProduced == false,
  );
  return eligible
      .map(
        (p) => _ProductOption(
          product: p,
          stock: stockMap[p.id] ?? p.currentStockQty,
        ),
      )
      .toList();
});
