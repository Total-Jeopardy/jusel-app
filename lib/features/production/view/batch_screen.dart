import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/production/view/new_batch_screen.dart';
import 'package:jusel_app/features/stock/view/batch_detail_screen.dart';

class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});

  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends State<BatchScreen> {
  static const _product = _ProductSummary(
    name: 'Homemade Lemonade',
    currentStock: 42,
  );

  final List<_BatchSummary> _batches = [
    _BatchSummary(
      id: 104,
      producedUnits: 20,
      totalCost: 14.50,
      unitCost: 0.73,
      date: DateTime.now(),
      tag: 'LOCAL DRINK',
    ),
    _BatchSummary(
      id: 103,
      producedUnits: 50,
      totalCost: 32.00,
      unitCost: 0.64,
      date: DateTime.now().subtract(const Duration(days: 3)),
      tag: 'LOCAL DRINK',
      note: 'Sugar reduced',
    ),
    _BatchSummary(
      id: 102,
      producedUnits: 45,
      totalCost: 29.50,
      unitCost: 0.66,
      date: DateTime.now().subtract(const Duration(days: 7)),
      tag: 'LOCAL DRINK',
    ),
    _BatchSummary(
      id: 101,
      producedUnits: 40,
      totalCost: 26.00,
      unitCost: 0.65,
      date: DateTime.now().subtract(const Duration(days: 10)),
      tag: 'LOCAL DRINK',
      note: 'New lemon supplier',
    ),
  ];

  DateFilter _dateFilter = DateFilter.all;
  SortOption _sort = SortOption.dateDesc;

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters(_batches);

    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
            onPressed: () {
              // TODO: open filter sheet
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewBatchScreen()),
              );
            },
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
              const _ProductCard(product: _product),
              const SizedBox(height: JuselSpacing.s20),
              _FilterRow(
                selected: _dateFilter,
                onSelected: (value) {
                  setState(() => _dateFilter = value);
                },
              ),
              const SizedBox(height: JuselSpacing.s16),
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
              ...filtered.map((batch) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: JuselSpacing.s12),
                    child: _BatchCard(
                      batch: batch,
                      productName: _product.name,
                    ),
                  )),
              const SizedBox(height: JuselSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }

  List<_BatchSummary> _applyFilters(List<_BatchSummary> batches) {
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
        ? List<_BatchSummary>.from(batches)
        : batches.where((b) => b.date.isAfter(cutoff!)).toList();

    list.sort((a, b) =>
        _sort == SortOption.dateDesc ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return list;
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
          // TODO: open product picker
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
                      'Product',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s6),
                    Text(
                      product.name,
                      style: JuselTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.currentStock.toString(),
                    style: JuselTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: JuselColors.primary,
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s4),
                  Text(
                    'Current Stock',
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: JuselColors.mutedForeground,
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
}

class _FilterRow extends StatelessWidget {
  final DateFilter selected;
  final ValueChanged<DateFilter> onSelected;

  const _FilterRow({
    required this.selected,
    required this.onSelected,
  });

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
              color: isActive ? JuselColors.primary : JuselColors.mutedForeground,
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
  final _BatchSummary batch;
  final String productName;

  const _BatchCard({
    required this.batch,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Calculate estimated values (assuming selling price is 2x unit cost for margin calculation)
          final estimatedSellingPrice = batch.unitCost * 2;
          final estimatedRevenue = estimatedSellingPrice * batch.producedUnits;
          final estimatedMargin = ((estimatedSellingPrice - batch.unitCost) / estimatedSellingPrice) * 100;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BatchDetailScreen(
                batchCode: 'Batch #${batch.id}',
                productName: productName,
                badgeLabel: batch.tag,
                producedAt: batch.date,
                supplier: 'Fresh Farms Ltd',
                producedUnits: batch.producedUnits,
                stockAdded: batch.producedUnits,
                totalCost: batch.totalCost,
                unitCost: batch.unitCost,
                unitCostChangePercent: -4.0, // Example: 4% decrease
                estimatedRevenue: estimatedRevenue,
                estimatedMarginPercent: estimatedMargin,
                costBreakdown: {
                  'Ingredients': batch.totalCost * 0.55,
                  'Packaging': batch.totalCost * 0.15,
                  'Labor': batch.totalCost * 0.20,
                  'Gas': batch.totalCost * 0.10,
                },
                notes: batch.note ?? 'Production ran smoothly. New lemon supplier tested for this batch, acidity is slightly higher.',
                relatedMovementLabel: 'Movement #${500 + batch.id}',
                relatedMovementDelta: batch.producedUnits,
              ),
            ),
          );
        },
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
                  _formatDate(batch.date),
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
                  value: '+${batch.producedUnits} units',
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
                    batch.tag,
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (batch.note != null) ...[
                  const SizedBox(width: JuselSpacing.s12),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_box_outline_blank_rounded,
                        size: 16,
                        color: JuselColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        batch.note!,
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

class _ProductSummary {
  final String name;
  final int currentStock;

  const _ProductSummary({
    required this.name,
    required this.currentStock,
  });
}

class _BatchSummary {
  final int id;
  final int producedUnits;
  final double totalCost;
  final double unitCost;
  final DateTime date;
  final String tag;
  final String? note;

  const _BatchSummary({
    required this.id,
    required this.producedUnits,
    required this.totalCost,
    required this.unitCost,
    required this.date,
    required this.tag,
    this.note,
  });
}

enum DateFilter { all, last7, last30 }

enum SortOption { dateDesc, dateAsc }
