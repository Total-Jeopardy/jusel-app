import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/production/view/new_batch_screen.dart';
import 'package:jusel_app/features/stock/view/batch_detail_screen.dart';

final _producedProductsProvider =
    FutureProvider.autoDispose<List<ProductsTableData>>((ref) async {
      final db = ref.read(appDatabaseProvider);
      final products = await db.productsDao.getAllProducts();
      return products.where((p) => p.isProduced == true).toList();
    });

class _BatchView {
  final ProductionBatchesTableData batch;
  final ProductsTableData product;
  const _BatchView({required this.batch, required this.product});
}

final _batchesProvider = FutureProvider.autoDispose
    .family<List<_BatchView>, String?>((ref, productId) async {
      final db = ref.read(appDatabaseProvider);
      final products = await db.productsDao.getAllProducts();
      final productMap = {for (var p in products) p.id: p};

      final batches = productId == null
          ? await db.productionBatchesDao.getAllBatches()
          : await db.productionBatchesDao.getBatchesForProduct(productId);

      return batches
          .where((b) => productMap[b.productId] != null)
          .map((b) => _BatchView(batch: b, product: productMap[b.productId]!))
          .toList();
    });

const _allProductsKey = '__all_products__';

class BatchScreen extends ConsumerStatefulWidget {
  final String? productId;

  const BatchScreen({super.key, this.productId});

  @override
  ConsumerState<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends ConsumerState<BatchScreen> {
  DateFilter _dateFilter = DateFilter.all;
  SortOption _sort = SortOption.dateDesc;
  String? _selectedProductId;
  late TextEditingController _searchController;
  String _searchQuery = '';
  Timer? _searchDebounce;
  String _activeCategory = 'All';

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.productId;
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final producedAsync = ref.watch(_producedProductsProvider);
    final batchesAsync = ref.watch(_batchesProvider(_selectedProductId));
    final allBatchesAsync = ref.watch(_batchesProvider(null));

    return Scaffold(
      backgroundColor: JuselColors.background(context),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
        title: const Text(
          'Production Batches',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt_outlined,
              color: JuselColors.primaryColor(context),
            ),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: producedAsync.maybeWhen(
              data: (products) {
                if (products.isEmpty || _selectedProductId == null) {
                  return null;
                }
                final match = products
                    .where((p) => p.id == _selectedProductId)
                    .toList();
                if (match.isEmpty) return null;
                return () {
                  final product = match.first;
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => NewBatchScreen(
                            productId: product.id,
                            productName: product.name,
                            productTags: product.category,
                            currentStock: product.currentStockQty,
                          ),
                        ),
                      )
                      .then(
                        (_) => ref.invalidate(
                          _batchesProvider(_selectedProductId),
                        ),
                      );
                };
              },
              orElse: () => null,
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Add New Batch',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              _selectedProductId == null
                  ? _OverviewSection(
                      producedAsync: producedAsync,
                      allBatchesAsync: allBatchesAsync,
                      dateFilter: _dateFilter,
                      searchController: _searchController,
                      searchQuery: _searchQuery,
                      activeCategory: _activeCategory,
                      onSearchChanged: _handleSearchChanged,
                      onCategorySelected: (cat) =>
                          setState(() => _activeCategory = cat),
                      onSelectProduct: (productId) =>
                          setState(() => _selectedProductId = productId),
                      onDateFilterChanged: (value) =>
                          setState(() => _dateFilter = value),
                    )
                  : _DetailSection(
                      producedAsync: producedAsync,
                      batchesAsync: batchesAsync,
                      dateFilter: _dateFilter,
                      sort: _sort,
                      selectedProductId: _selectedProductId,
                      onDateFilterChanged: (value) =>
                          setState(() => _dateFilter = value),
                      onSortTapped: () {
                        setState(() {
                          _sort = _sort == SortOption.dateDesc
                              ? SortOption.dateAsc
                              : SortOption.dateDesc;
                        });
                      },
                      onChangeProduct: (choice) {
                        if (choice == null) return;
                        setState(
                          () => _selectedProductId = choice == _allProductsKey
                              ? null
                              : choice,
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _searchQuery = value.toLowerCase().trim());
      }
    });
  }

  List<_BatchView> _filterByDate(List<_BatchView> batches) {
    final now = DateTime.now();
    DateTime? cutoff;
    switch (_dateFilter) {
      case DateFilter.last7:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case DateFilter.last30:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case DateFilter.all:
        cutoff = null;
        break;
    }

    return cutoff == null
        ? List<_BatchView>.from(batches)
        : batches.where((b) => b.batch.createdAt.isAfter(cutoff!)).toList();
  }
}

class _OverviewSection extends StatelessWidget {
  final AsyncValue<List<ProductsTableData>> producedAsync;
  final AsyncValue<List<_BatchView>> allBatchesAsync;
  final DateFilter dateFilter;
  final TextEditingController searchController;
  final String searchQuery;
  final String activeCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<DateFilter> onDateFilterChanged;
  final ValueChanged<String> onSelectProduct;

  const _OverviewSection({
    required this.producedAsync,
    required this.allBatchesAsync,
    required this.dateFilter,
    required this.searchController,
    required this.searchQuery,
    required this.activeCategory,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onDateFilterChanged,
    required this.onSelectProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search produced products...',
            prefixIcon: const Icon(Icons.search, size: 20),
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
        const SizedBox(height: JuselSpacing.s12),
        producedAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(JuselSpacing.s12),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(JuselSpacing.s12),
            child: Text(
              'Failed to load products: $e',
              style: JuselTextStyles.bodyMedium(context).copyWith(
                color: JuselColors.destructiveColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          data: (products) {
            final categories = _buildCategories(products);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: JuselSpacing.s12),
                  child: Row(
                    children: categories
                        .map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: activeCategory == cat,
                              onSelected: (_) => onCategorySelected(cat),
                              labelStyle: JuselTextStyles.bodySmall(context).copyWith(
                                fontWeight: FontWeight.w700,
                                color: activeCategory == cat
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
                _FilterRow(
                  selected: dateFilter,
                  onSelected: onDateFilterChanged,
                ),
                const SizedBox(height: JuselSpacing.s16),
                allBatchesAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(JuselSpacing.s12),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(JuselSpacing.s12),
                    child: Text(
                      'Failed to load batches: $e',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.destructiveColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  data: (batches) {
                    final summaries = _buildSummaries(
                      products,
                      batches,
                      searchQuery,
                      activeCategory,
                      dateFilter,
                    );
                    if (summaries.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(JuselSpacing.s12),
                        child: Text(
                          'No produced products match your filters.',
                          style: JuselTextStyles.bodyMedium(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: summaries
                          .map(
                            (summary) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: JuselSpacing.s12,
                              ),
                              child: _OverviewCard(
                                product: summary.product,
                                batchCount: summary.batchCount,
                                latestBatch: summary.latestBatch,
                                onTap: () =>
                                    onSelectProduct(summary.product.id),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<String> _buildCategories(List<ProductsTableData> products) {
    final set = products.map((p) => p.category).toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['All', ...set];
  }

  List<_ProductSummaryItem> _buildSummaries(
    List<ProductsTableData> products,
    List<_BatchView> batches,
    String query,
    String category,
    DateFilter filter,
  ) {
    final filteredProducts = products.where((p) {
      final matchesQuery =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      final matchesCategory =
          category == 'All' ||
          p.category.toLowerCase() == category.toLowerCase();
      return matchesQuery && matchesCategory;
    }).toList();

    final cutoff = _cutoffForFilter(filter);
    List<_BatchView> filteredBatches = batches;
    if (cutoff != null) {
      filteredBatches = batches
          .where((b) => b.batch.createdAt.isAfter(cutoff))
          .toList();
    }

    final grouped = <String, List<_BatchView>>{};
    for (final b in filteredBatches) {
      grouped.putIfAbsent(b.product.id, () => []).add(b);
    }

    return filteredProducts.map((p) {
      final list = grouped[p.id] ?? [];
      list.sort((a, b) => b.batch.createdAt.compareTo(a.batch.createdAt));
      return _ProductSummaryItem(
        product: p,
        batchCount: list.length,
        latestBatch: list.isEmpty ? null : list.first.batch,
      );
    }).toList();
  }

  DateTime? _cutoffForFilter(DateFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case DateFilter.last7:
        return now.subtract(const Duration(days: 7));
      case DateFilter.last30:
        return now.subtract(const Duration(days: 30));
      case DateFilter.all:
        return null;
    }
  }
}

class _ProductSummaryItem {
  final ProductsTableData product;
  final int batchCount;
  final ProductionBatchesTableData? latestBatch;

  const _ProductSummaryItem({
    required this.product,
    required this.batchCount,
    required this.latestBatch,
  });
}

class _OverviewCard extends StatelessWidget {
  final ProductsTableData product;
  final int batchCount;
  final ProductionBatchesTableData? latestBatch;
  final VoidCallback onTap;

  const _OverviewCard({
    required this.product,
    required this.batchCount,
    required this.latestBatch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(JuselSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: JuselTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
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
                      '${batchCount} batch${batchCount == 1 ? '' : 'es'}',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.successColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s6),
              Text(
                product.category,
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: JuselSpacing.s12),
              if (latestBatch == null)
                Text(
                  'No batches yet — tap to add the first batch',
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Latest: +${latestBatch!.quantityProduced} units',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground(context),
                      ),
                    ),
                    Text(
                      _formatDate(latestBatch!.createdAt),
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) {
      final time = TimeOfDay.fromDateTime(date);
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return 'Today, $hour:$minute $period';
    }
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _DetailSection extends StatelessWidget {
  final AsyncValue<List<ProductsTableData>> producedAsync;
  final AsyncValue<List<_BatchView>> batchesAsync;
  final DateFilter dateFilter;
  final SortOption sort;
  final String? selectedProductId;
  final ValueChanged<DateFilter> onDateFilterChanged;
  final VoidCallback onSortTapped;
  final ValueChanged<String?> onChangeProduct;

  const _DetailSection({
    required this.producedAsync,
    required this.batchesAsync,
    required this.dateFilter,
    required this.sort,
    required this.selectedProductId,
    required this.onDateFilterChanged,
    required this.onSortTapped,
    required this.onChangeProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        producedAsync.when(
          loading: () => const _ProductCard(product: null),
          error: (e, _) => const _ProductCard(
            product: null,
            errorText: 'Failed to load products',
          ),
          data: (products) {
            ProductsTableData? selected;
            if (selectedProductId != null) {
              final match = products
                  .where((p) => p.id == selectedProductId)
                  .toList();
              if (match.isNotEmpty) {
                selected = match.first;
              }
            }
            return _ProductCard(
              product: selected,
              productCount: products.length,
              onTap: products.isEmpty
                  ? null
                  : () async {
                      final choice = await showModalBottomSheet<String?>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return _ProductPicker(
                            products: products,
                            selectedId: selectedProductId,
                          );
                        },
                      );
                      onChangeProduct(choice);
                    },
            );
          },
        ),
        const SizedBox(height: JuselSpacing.s20),
        _FilterRow(selected: dateFilter, onSelected: onDateFilterChanged),
        const SizedBox(height: JuselSpacing.s16),
        batchesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(JuselSpacing.s12),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(JuselSpacing.s12),
            child: Text(
              'Failed to load batches: $e',
              style: JuselTextStyles.bodyMedium(context).copyWith(
                color: JuselColors.destructiveColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          data: (batches) {
            final filtered = _applyFiltersStatic(batches, dateFilter, sort);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ListHeader(
                  count: filtered.length,
                  sortOption: sort,
                  onSortTapped: onSortTapped,
                ),
                const SizedBox(height: JuselSpacing.s12),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(JuselSpacing.s12),
                    child: Text(
                      'No batches found for this product.',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (batch) => Padding(
                      padding: const EdgeInsets.only(bottom: JuselSpacing.s12),
                      child: _BatchCard(
                        batch: batch.batch,
                        productName: batch.product.name,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BatchDetailScreen(batchId: batch.batch.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: JuselSpacing.s12),
              ],
            );
          },
        ),
      ],
    );
  }

  static List<_BatchView> _applyFiltersStatic(
    List<_BatchView> batches,
    DateFilter filter,
    SortOption sort,
  ) {
    final now = DateTime.now();
    DateTime? cutoff;
    switch (filter) {
      case DateFilter.last7:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case DateFilter.last30:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case DateFilter.all:
        cutoff = null;
        break;
    }

    final filtered = cutoff == null
        ? List<_BatchView>.from(batches)
        : batches.where((b) => b.batch.createdAt.isAfter(cutoff!)).toList();

    filtered.sort(
      (a, b) => sort == SortOption.dateDesc
          ? b.batch.createdAt.compareTo(a.batch.createdAt)
          : a.batch.createdAt.compareTo(b.batch.createdAt),
    );
    return filtered;
  }
}

class _ProductCard extends StatelessWidget {
  final ProductsTableData? product;
  final int? productCount;
  final VoidCallback? onTap;
  final String? errorText;

  const _ProductCard({
    required this.product,
    this.productCount,
    this.onTap,
    this.errorText,
  });

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
                    Row(
                      children: [
                        Text(
                          'Product',
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (productCount != null) ...[
                          const SizedBox(width: JuselSpacing.s6),
                          Text(
                            '(${productCount == 0 ? 'None' : productCount})',
                            style: JuselTextStyles.bodySmall(context).copyWith(
                              color: JuselColors.mutedForeground(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s6),
                    if (product == null && errorText != null)
                      Text(
                        errorText!,
                        style: JuselTextStyles.bodyMedium(context).copyWith(
                          color: JuselColors.destructiveColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text(
                        product?.name ?? 'Select a product to view batches',
                        style: JuselTextStyles.headlineSmall(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: JuselColors.foreground(context),
                        ),
                      ),
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
  final List<ProductsTableData> products;
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
    final set = widget.products.map((p) => p.category).toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['All', ...set];
  }

  List<ProductsTableData> get _filtered {
    final base = widget.products.where((p) {
      if (_searchQuery.isEmpty) return true;
      final name = p.name.toLowerCase();
      final cat = p.category.toLowerCase();
      return name.contains(_searchQuery) || cat.contains(_searchQuery);
    }).toList();

    if (_activeCategory == 'All') return base;
    return base
        .where((p) => p.category.toLowerCase() == _activeCategory.toLowerCase())
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
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All Products'),
                      selected: widget.selectedId == null,
                      onSelected: (_) =>
                          Navigator.pop(context, _allProductsKey),
                      labelStyle: JuselTextStyles.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.selectedId == null
                            ? JuselColors.primaryForeground
                            : JuselColors.foreground(context),
                      ),
                      selectedColor: JuselColors.primaryColor(context),
                      backgroundColor: JuselColors.card(context),
                      side: BorderSide(color: JuselColors.border(context)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  ..._categories.map(
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
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
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
                        final product = filtered[index];
                        final selected = widget.selectedId == product.id;
                        return _ProductPickerItem(
                          product: product,
                          selected: selected,
                          onTap: () => Navigator.pop(context, product.id),
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
  final ProductsTableData product;
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
                        product.name,
                        style: JuselTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.category.trim().isNotEmpty) ...[
                        const SizedBox(height: JuselSpacing.s4),
                        Text(
                          product.category,
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

class _FilterRow extends StatelessWidget {
  final DateFilter selected;
  final ValueChanged<DateFilter> onSelected;

  const _FilterRow({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: JuselColors.muted(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: JuselSpacing.s8,
          vertical: JuselSpacing.s8,
        ),
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isActive: selected == DateFilter.all,
              onTap: () => onSelected(DateFilter.all),
            ),
            _FilterChip(
              label: 'Last 7 Days',
              isActive: selected == DateFilter.last7,
              onTap: () => onSelected(DateFilter.last7),
            ),
            _FilterChip(
              label: 'Last 30 Days',
              isActive: selected == DateFilter.last30,
              onTap: () => onSelected(DateFilter.last30),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? JuselColors.card(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: JuselTextStyles.bodySmall(context).copyWith(
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

class _ListHeader extends StatelessWidget {
  final int count;
  final SortOption sortOption;
  final VoidCallback onSortTapped;

  const _ListHeader({
    required this.count,
    required this.sortOption,
    required this.onSortTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count Batches',
          style: JuselTextStyles.bodySmall(context).copyWith(
            color: JuselColors.mutedForeground(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        InkWell(
          onTap: onSortTapped,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Text(
                'Sort by: Date',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.primaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Transform.rotate(
                angle: sortOption == SortOption.dateDesc ? 0 : 3.14,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: JuselColors.primaryColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BatchCard extends StatelessWidget {
  final ProductionBatchesTableData batch;
  final String productName;
  final VoidCallback? onTap;

  const _BatchCard({
    required this.batch,
    required this.productName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(JuselSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#  Batch #${batch.id}',
                    style: JuselTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: JuselColors.foreground(context),
                    ),
                  ),
                  Text(
                    _formatDate(batch.createdAt),
                    style: JuselTextStyles.bodySmall(context).copyWith(
                      color: JuselColors.mutedForeground(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricColumn(
                    label: 'Produced',
                    value: '+${batch.quantityProduced} units',
                  ),
                  _MetricColumn(
                    label: 'Total Cost',
                    value: 'GHS ${batch.totalCost.toStringAsFixed(2)}',
                  ),
                  _MetricColumn(
                    label: 'Unit Cost',
                    value: 'GHS ${batch.unitCost.toStringAsFixed(2)}',
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      productName,
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.successColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (batch.notes?.isNotEmpty == true) ...[
                    const SizedBox(width: JuselSpacing.s12),
                    Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 16,
                          color: JuselColors.mutedForeground(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          batch.notes ?? '',
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) {
      final time = TimeOfDay.fromDateTime(date);
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return 'Today, $hour:$minute $period';
    }
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;

  const _MetricColumn({required this.label, required this.value});

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
        Text(
          value,
          style: JuselTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground(context),
          ),
        ),
      ],
    );
  }
}

enum DateFilter { all, last7, last30 }

enum SortOption { dateDesc, dateAsc }
