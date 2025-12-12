import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_tab_provider.dart';
import 'package:jusel_app/features/production/providers.dart';
import 'package:jusel_app/features/stock/view/batch_detail_screen.dart';

final _producedProductsProvider =
    FutureProvider.autoDispose<List<_ProductOption>>((ref) async {
      final db = ref.read(appDatabaseProvider);
      final inventory = ref.read(inventoryServiceProvider);
      final products = await db.productsDao.getAllProducts();
      final stockMap = await inventory.getAllCurrentStock();
      final produced = products.where((p) => p.isProduced == true);
      return produced
          .map(
            (p) => _ProductOption(
              product: p,
              stock: stockMap[p.id] ?? p.currentStockQty,
            ),
          )
          .toList();
    });

class NewBatchScreen extends ConsumerStatefulWidget {
  final String? productId;
  final String? productName;
  final String? productTags;
  final int? currentStock;

  const NewBatchScreen({
    super.key,
    this.productId,
    this.productName,
    this.productTags,
    this.currentStock,
  });

  @override
  ConsumerState<NewBatchScreen> createState() => _NewBatchScreenState();
}

class _NewBatchScreenState extends ConsumerState<NewBatchScreen> {
  final TextEditingController _qtyController = TextEditingController(
    text: '20',
  );
  final TextEditingController _notesController = TextEditingController();
  final List<String> _recipes = [
    'Standard Recipe',
    'Low Sugar Variant',
    'Bulk',
  ];
  String _selectedRecipe = 'Standard Recipe';
  final List<_CostItem> _costItems = [
    const _CostItem(type: 'Ingredients', amount: 12.0),
  ];
  bool _saving = false;
  String? _selectedProductId;
  _ProductOption? _selectedProduct;
  bool _initializedSelection = false;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.productId;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(_producedProductsProvider);
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
          'New Production Batch',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving || _selectedProduct == null ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(JuselColors.primaryForeground),
                    ),
                  )
                : const Text(
                    'Save Batch',
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
              Divider(height: 1, color: JuselColors.border(context)),
              const SizedBox(height: JuselSpacing.s16),
              Text(
                'Product',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              productsAsync.when(
                loading: () => const _ProductCard(),
                error: (e, _) =>
                    const _ProductCard(errorText: 'Failed to load products'),
                data: (products) {
                  if (!_initializedSelection && products.isNotEmpty) {
                    final initialId = widget.productId ?? _selectedProductId;
                    if (initialId != null && initialId.isNotEmpty) {
                      final match = products
                          .where((p) => p.product.id == initialId)
                          .toList();
                      if (match.isNotEmpty) {
                        _selectedProductId = match.first.product.id;
                        _selectedProduct = match.first;
                      }
                    }
                    _initializedSelection = true;
                  }
                  final summary = _selectedProduct == null
                      ? null
                      : _ProductSummary(
                          name: _selectedProduct!.product.name,
                          tags: _selectedProduct!.product.category,
                          currentStock: _selectedProduct!.stock,
                        );
                  return _ProductCard(
                    product: summary,
                    onTap: products.isEmpty
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
                            });
                          },
                  );
                },
              ),
              const SizedBox(height: JuselSpacing.s16),
              Container(
                decoration: BoxDecoration(
                  color: JuselColors.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: JuselColors.border(context)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(JuselSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity Produced (Units)',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s8),
                    _QtyField(controller: _qtyController),
                    const SizedBox(height: JuselSpacing.s16),
                    Text(
                      'Production Type',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s8),
                    const _ProductionTypeCard(),
                  ],
                ),
              ),
              const SizedBox(height: JuselSpacing.s20),
              Text(
                'Recipe Templates',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              _RecipeChips(
                recipes: _recipes,
                selected: _selectedRecipe,
                onSelected: (value) {
                  setState(() => _selectedRecipe = value);
                },
              ),
              const SizedBox(height: JuselSpacing.s20),
              Text(
                'Cost Breakdown',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              _CostBreakdownCard(
                items: _costItems,
                onAdd: () {
                  setState(() {
                    _costItems.add(
                      const _CostItem(type: 'Ingredients', amount: 0),
                    );
                  });
                },
                onRemove: (index) {
                  setState(() {
                    _costItems.removeAt(index);
                  });
                },
                onAmountChanged: (index, value) {
                  setState(() {
                    _costItems[index] = _costItems[index].copyWith(
                      amount: value,
                    );
                  });
                },
                onTypeChanged: (index, value) {
                  setState(() {
                    _costItems[index] = _costItems[index].copyWith(type: value);
                  });
                },
              ),
              const SizedBox(height: JuselSpacing.s20),
              Text(
                'Notes (optional)',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any details about this batch...',
                  filled: true,
                  fillColor: JuselColors.muted(context),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: JuselColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: JuselColors.primaryColor(context)),
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: JuselColors.destructive,
      ),
    );
  }

  double _sumCost(String key) {
    return _costItems
        .where((item) => item.type.toLowerCase() == key.toLowerCase())
        .fold<double>(0, (prev, item) => prev + item.amount);
  }

  double _totalCost() {
    return _costItems.fold<double>(0, (prev, item) => prev + item.amount);
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (qty <= 0) {
      _showError('Enter a valid quantity produced.');
      return;
    }

    if (_selectedProductId == null || _selectedProduct == null) {
      _showError('Select a product to continue.');
      return;
    }

    final totalCost = _totalCost();
    if (totalCost <= 0) {
      _showError('Add at least one cost item greater than zero.');
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final user = authState.valueOrNull;
    if (user == null) {
      _showError('Please log in to save a batch.');
      return;
    }

    final productionService = ref.read(productionServiceProvider);

    setState(() => _saving = true);
    try {
      final summary = await productionService.createBatch(
        productId: _selectedProductId!,
        quantityProduced: qty,
        ingredientsCost: _sumCost('ingredients'),
        gasCost: _sumCost('gas'),
        oilCost: _sumCost('oil'),
        laborCost: _sumCost('labor'),
        transportCost: _sumCost('transport'),
        packagingCost: _sumCost('packaging'),
        otherCost: _sumCost('other'),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdByUserId: user.uid,
      );

      // Refresh dashboard metrics/stock after production
      ref.invalidate(dashboardProvider);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BatchDetailScreen(batchId: summary.batchId),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showError(
          e.toString().replaceFirst('ProductionServiceException: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: JuselColors.card(context),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                        style: JuselTextStyles.bodyMedium(context).copyWith(
                          color: JuselColors.destructive,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else if (product == null)
                      Text(
                        'Select a product to add batch',
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
                      const SizedBox(height: JuselSpacing.s6),
                      Text(
                        product!.tags,
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: JuselColors.successColor(context).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: JuselColors.successColor(context),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Current Stock: ${product!.currentStock} units',
                              style: JuselTextStyles.bodySmall(context).copyWith(
                                color: JuselColors.successColor(context),
                                fontWeight: FontWeight.w700,
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
  String _activeCategory = 'All';

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
    });
  }

  List<String> get _categories {
    final set = widget.products.map((p) => p.product.category).toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['All', ...set];
  }

  List<_ProductOption> get _filtered {
    final base = widget.products.where((p) {
      if (_searchQuery.isEmpty) return true;
      final name = p.product.name.toLowerCase();
      final cat = p.product.category.toLowerCase();
      return name.contains(_searchQuery) || cat.contains(_searchQuery);
    }).toList();

    if (_activeCategory == 'All') return base;
    return base
        .where(
          (p) =>
              p.product.category.toLowerCase() == _activeCategory.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    final filtered = _filtered;
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
                                ? '${widget.products.length} products'
                                : '${filtered.length} results',
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
                children: _categories
                    .map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: _activeCategory == cat,
                          onSelected: (_) => setState(() {
                            _activeCategory = cat;
                          }),
                          labelStyle: JuselTextStyles.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: _activeCategory == cat
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
            Expanded(
              child: filtered.isEmpty
                  ? _EmptySearchState(
                      query: _searchQuery.isEmpty
                          ? _activeCategory
                          : _searchQuery,
                      onClear: _clearSearch,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: JuselSpacing.s20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final selected = widget.selectedId == item.product.id;
                        return _ProductPickerItem(
                          product: item,
                          selected: selected,
                          onTap: () => Navigator.pop(context, item.product.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPickerItem extends StatelessWidget {
  final _ProductOption product;
  final bool selected;
  final VoidCallback onTap;

  const _ProductPickerItem({
    required this.product,
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
                        product.product.name,
                        style: JuselTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.product.category.trim().isNotEmpty) ...[
                        const SizedBox(height: JuselSpacing.s4),
                        Text(
                          product.product.category,
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                          'Stock: ${product.stock}',
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
              'No results for "' + query + '"',
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

class _QtyField extends StatelessWidget {
  final TextEditingController controller;

  const _QtyField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: '0',
        suffixIcon: Icon(
          Icons.edit,
          size: 18,
          color: JuselColors.mutedForeground(context),
        ),
        filled: true,
        fillColor: JuselColors.muted(context),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: JuselColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: JuselColors.primaryColor(context), width: 1.2),
        ),
      ),
    );
  }
}

class _ProductionTypeCard extends StatelessWidget {
  const _ProductionTypeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: JuselColors.muted(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border(context)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: JuselColors.accentColor(context).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_drink_outlined,
                  size: 16,
                  color: JuselColors.accentColor(context),
                ),
                const SizedBox(width: 6),
                Text(
                  'Local Drink',
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.accentColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Auto-detected',
            style: JuselTextStyles.bodySmall(context).copyWith(
              color: JuselColors.mutedForeground(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeChips extends StatelessWidget {
  final List<String> recipes;
  final String selected;
  final ValueChanged<String> onSelected;

  const _RecipeChips({
    required this.recipes,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: recipes.map((recipe) {
          final isActive = recipe == selected;
          return Padding(
            padding: const EdgeInsets.only(right: JuselSpacing.s8),
            child: InkWell(
              onTap: () => onSelected(recipe),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? JuselColors.primaryColor(context).withOpacity(0.12) : JuselColors.card(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? JuselColors.primaryColor(context)
                        : JuselColors.border(context),
                  ),
                ),
                child: Row(
                  children: [
                    if (isActive)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.edit_calendar_outlined,
                          size: 16,
                          color: JuselColors.primaryColor(context),
                        ),
                      ),
                    Text(
                      recipe,
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? JuselColors.primaryColor(context)
                            : JuselColors.foreground(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CostBreakdownCard extends StatelessWidget {
  final List<_CostItem> items;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int index, double value) onAmountChanged;
  final void Function(int index, String value) onTypeChanged;

  const _CostBreakdownCard({
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.onAmountChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: JuselColors.card(context),
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review costs for Local Drink batch.',
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.foreground(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: JuselSpacing.s12),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == items.length - 1 ? 0 : JuselSpacing.s12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: JuselColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: JuselColors.border(context)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: JuselSpacing.s12,
                    vertical: JuselSpacing.s8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: item.type,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(12),
                            items: const [
                              DropdownMenuItem(
                                value: 'Ingredients',
                                child: Text('Ingredients'),
                              ),
                              DropdownMenuItem(
                                value: 'Labor',
                                child: Text('Labor'),
                              ),
                              DropdownMenuItem(
                                value: 'Packaging',
                                child: Text('Packaging'),
                              ),
                              DropdownMenuItem(
                                value: 'Transport',
                                child: Text('Transport'),
                              ),
                              DropdownMenuItem(
                                value: 'Gas',
                                child: Text('Gas'),
                              ),
                              DropdownMenuItem(
                                value: 'Oil',
                                child: Text('Oil'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) onTypeChanged(index, val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: JuselSpacing.s12),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: TextEditingController(
                            text: item.amount.toStringAsFixed(2),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          onChanged: (val) {
                            final parsed = double.tryParse(val) ?? 0;
                            onAmountChanged(index, parsed < 0 ? 0 : parsed);
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: JuselColors.muted(context),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: JuselSpacing.s12,
                              vertical: JuselSpacing.s8,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: JuselColors.border(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: JuselColors.primaryColor(context),
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: JuselSpacing.s8),
                      InkWell(
                        onTap: () => onRemove(index),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: JuselColors.destructiveColor(context).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: JuselColors.destructiveColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: JuselSpacing.s12),
            OutlinedButton.icon(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: JuselColors.border(context)),
                padding: const EdgeInsets.symmetric(
                  vertical: JuselSpacing.s12,
                  horizontal: JuselSpacing.s12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.add, color: JuselColors.primaryColor(context)),
              label: Text(
                'Add Cost Item',
                style: JuselTextStyles.bodySmall(context).copyWith(
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

class _ProductSummary {
  final String name;
  final String tags;
  final int currentStock;

  const _ProductSummary({
    required this.name,
    required this.tags,
    required this.currentStock,
  });
}

class _ProductOption {
  final ProductsTableData product;
  final int stock;

  const _ProductOption({required this.product, required this.stock});
}

class _CostItem {
  final String type;
  final double amount;

  const _CostItem({required this.type, required this.amount});

  _CostItem copyWith({String? type, double? amount}) {
    return _CostItem(type: type ?? this.type, amount: amount ?? this.amount);
  }
}
