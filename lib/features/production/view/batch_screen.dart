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

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.productId;
  }

  @override
  Widget build(BuildContext context) {
    final producedAsync = ref.watch(_producedProductsProvider);
    final batchesAsync = ref.watch(_batchesProvider(_selectedProductId));

    return Scaffold(
      backgroundColor: JuselColors.background,
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
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: JuselColors.primary,
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
                if (products.isEmpty) return null;
                return () {
                  final product = products.firstWhere(
                    (p) => p.id == _selectedProductId,
                    orElse: () => products.first,
                  );
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
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: JuselSpacing.s16),
              producedAsync.when(
                loading: () => const _ProductCard(product: null),
                error: (e, _) => const _ProductCard(
                  product: null,
                  errorText: 'Failed to load products',
                ),
                data: (products) {
                  ProductsTableData? selected;
                  if (products.isNotEmpty) {
                    selected = products.firstWhere(
                      (p) => p.id == _selectedProductId,
                      orElse: () => products.first,
                    );
                  }
                  return _ProductCard(
                    product: selected,
                    productCount: products.length,
                    onTap: products.isEmpty
                        ? null
                        : () async {
                            final choice = await showModalBottomSheet<String?>(
                              context: context,
                              builder: (context) {
                                return _ProductPicker(
                                  products: products,
                                  selectedId: _selectedProductId,
                                );
                              },
                            );
                            if (choice == null) return;
                            setState(
                              () => _selectedProductId =
                                  choice == _allProductsKey ? null : choice,
                            );
                          },
                  );
                },
              ),
              const SizedBox(height: JuselSpacing.s20),
              _FilterRow(
                selected: _dateFilter,
                onSelected: (value) {
                  setState(() => _dateFilter = value);
                },
              ),
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
                    style: JuselTextStyles.bodyMedium.copyWith(
                      color: JuselColors.destructive,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                data: (batches) {
                  final filtered = _applyFilters(batches);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ListHeader(
                        count: filtered.length,
                        sortOption: _sort,
                        onSortTapped: () {
                          setState(() {
                            _sort = _sort == SortOption.dateDesc
                                ? SortOption.dateAsc
                                : SortOption.dateDesc;
                          });
                        },
                      ),
                      const SizedBox(height: JuselSpacing.s12),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(JuselSpacing.s12),
                          child: Text(
                            'No batches found.',
                            style: JuselTextStyles.bodyMedium.copyWith(
                              color: JuselColors.mutedForeground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        ...filtered.map(
                          (batch) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: JuselSpacing.s12,
                            ),
                            child: _BatchCard(
                              batch: batch.batch,
                              productName: batch.product.name,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BatchDetailScreen(
                                      batchId: batch.batch.id,
                                    ),
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
          ),
        ),
      ),
    );
  }

  List<_BatchView> _applyFilters(List<_BatchView> batches) {
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

    var list = cutoff == null
        ? List<_BatchView>.from(batches)
        : batches.where((b) => b.batch.createdAt.isAfter(cutoff!)).toList();

    list.sort(
      (a, b) => _sort == SortOption.dateDesc
          ? b.batch.createdAt.compareTo(a.batch.createdAt)
          : a.batch.createdAt.compareTo(b.batch.createdAt),
    );
    return list;
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
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: JuselColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (productCount != null) ...[
                          const SizedBox(width: JuselSpacing.s6),
                          Text(
                            '(${productCount == 0 ? 'None' : productCount})',
                            style: JuselTextStyles.bodySmall.copyWith(
                              color: JuselColors.mutedForeground,
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
                        style: JuselTextStyles.bodyMedium.copyWith(
                          color: JuselColors.destructive,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text(
                        product?.name ?? 'All Products',
                        style: JuselTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: JuselColors.foreground,
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

class _ProductPicker extends StatelessWidget {
  final List<ProductsTableData> products;
  final String? selectedId;

  const _ProductPicker({required this.products, required this.selectedId});

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
          ListTile(
            onTap: () => Navigator.pop(context, _allProductsKey),
            title: const Text('All Products'),
            trailing: selectedId == null
                ? const Icon(Icons.check, color: JuselColors.primary)
                : null,
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = products[index];
                final selected = selectedId == product.id;
                return ListTile(
                  onTap: () => Navigator.pop(context, product.id),
                  title: Text(
                    product.name,
                    style: JuselTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: product.category.trim().isNotEmpty
                      ? Text(
                          product.category,
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: JuselColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
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

class _FilterRow extends StatelessWidget {
  final DateFilter selected;
  final ValueChanged<DateFilter> onSelected;

  const _FilterRow({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF7F9FE),
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
            color: isActive ? Colors.white : Colors.transparent,
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
            style: JuselTextStyles.bodySmall.copyWith(
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
          style: JuselTextStyles.bodySmall.copyWith(
            color: JuselColors.mutedForeground,
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
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Transform.rotate(
                angle: sortOption == SortOption.dateDesc ? 0 : 3.14,
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: JuselColors.primary,
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
                    style: JuselTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: JuselColors.foreground,
                    ),
                  ),
                  Text(
                    _formatDate(batch.createdAt),
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: JuselColors.mutedForeground,
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
                      color: const Color(0xFFE9F8EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      productName,
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (batch.notes?.isNotEmpty == true) ...[
                    const SizedBox(width: JuselSpacing.s12),
                    Row(
                      children: [
                        const Icon(
                          Icons.note_outlined,
                          size: 16,
                          color: JuselColors.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          batch.notes ?? '',
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: JuselColors.mutedForeground,
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
          style: JuselTextStyles.bodySmall.copyWith(
            color: JuselColors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: JuselSpacing.s6),
        Text(
          value,
          style: JuselTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground,
          ),
        ),
      ],
    );
  }
}

enum DateFilter { all, last7, last30 }

enum SortOption { dateDesc, dateAsc }
