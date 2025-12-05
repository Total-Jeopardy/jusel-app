import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';

final stockMovementsProvider = FutureProvider.autoDispose
    .family<List<StockMovementsTableData>, String>((ref, productId) async {
      final db = ref.read(appDatabaseProvider);
      return db.stockMovementsDao.getMovementsForProduct(productId);
    });

class StockHistoryScreen extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final int currentStock;
  final String? imageAsset;

  const StockHistoryScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.currentStock,
    this.imageAsset,
  });

  @override
  ConsumerState<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends ConsumerState<StockHistoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final movementsAsync = ref.watch(stockMovementsProvider(widget.productId));

    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: JuselColors.border, width: 1),
        ),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            decoration: const BoxDecoration(
              color: JuselColors.muted,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  safePop(context, fallbackRoute: '/boss-dashboard'),
            ),
          ),
        ),
        title: const Text(
          'Stock History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.imageAsset != null) ...[
                    _ProductThumbnail(imageAsset: widget.imageAsset),
                    const SizedBox(width: JuselSpacing.s12),
                  ],
                  Expanded(
                    child: Text(
                      widget.productName,
                      style: JuselTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: JuselSpacing.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.currentStock.toString(),
                        style: JuselTextStyles.headlineMedium.copyWith(
                          color: JuselColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s2),
                      Text(
                        'Current Stock',
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: JuselColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s16),
              const Divider(height: 1, color: JuselColors.border),
              const SizedBox(height: JuselSpacing.s12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in const [
                      'All',
                      'Sales',
                      'Restocks',
                      'Production',
                      'Adjustments',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _FilterChip(
                          label: filter,
                          selected: _selectedFilter == filter,
                          onTap: () => setState(() => _selectedFilter = filter),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: JuselSpacing.s16),
              movementsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: JuselSpacing.s24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: JuselSpacing.s16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Failed to load movements',
                        style: JuselTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: JuselColors.destructive,
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s8),
                      Text(
                        e.toString(),
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: JuselColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s12),
                      OutlinedButton(
                        onPressed: () => ref.refresh(
                          stockMovementsProvider(widget.productId),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (movements) {
                  final filtered = movements.where((m) {
                    if (_selectedFilter == 'All') return true;
                    return _filterLabelForType(m.type) == _selectedFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(JuselSpacing.s16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: JuselColors.border),
                      ),
                      child: Text(
                        'No stock movements yet.',
                        style: JuselTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: JuselColors.mutedForeground,
                        ),
                      ),
                    );
                  }

                  final grouped = _groupByDay(filtered);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: grouped.entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: JuselSpacing.s12,
                            ),
                            child: _DaySection(
                              title: entry.key,
                              items: entry.value
                                  .map((m) => _MovementCard(m))
                                  .toList(),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _DaySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: JuselTextStyles.bodySmall.copyWith(
            color: JuselColors.mutedForeground,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        ...items
            .map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: JuselSpacing.s8),
                child: w,
              ),
            )
            .toList(),
      ],
    );
  }
}

class _MovementCard extends StatelessWidget {
  final StockMovementsTableData movement;
  const _MovementCard(this.movement);

  @override
  Widget build(BuildContext context) {
    final meta = _movementMeta(movement);
    final deltaColor = meta.isAddition
        ? JuselColors.success
        : JuselColors.destructive;
    final deltaPrefix = meta.isAddition ? '+' : '-';
    final reasonText = movement.reason != null && movement.reason!.isNotEmpty
        ? ' - ${movement.reason!.replaceAll('_', ' ')}'
        : '';
    final subtitle =
        '${DateFormat('MMM d, h:mm a').format(movement.createdAt)}$reasonText';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border),
      ),
      padding: const EdgeInsets.all(JuselSpacing.s16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: meta.badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.badge, color: meta.badgeIconColor),
          ),
          const SizedBox(width: JuselSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.title,
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  subtitle,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (movement.reason != null &&
                    movement.reason!.trim().isNotEmpty) ...[
                  const SizedBox(height: JuselSpacing.s6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: JuselSpacing.s12,
                      vertical: JuselSpacing.s6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: JuselColors.border),
                    ),
                    child: Text(
                      movement.reason!,
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: JuselSpacing.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$deltaPrefix${meta.displayDelta}',
                style: JuselTextStyles.bodyMedium.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: JuselSpacing.s12,
          vertical: JuselSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : JuselColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : JuselColors.mutedForeground,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final String? imageAsset;
  const _ProductThumbnail({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: JuselColors.muted,
        image: imageAsset != null
            ? DecorationImage(image: AssetImage(imageAsset!), fit: BoxFit.cover)
            : null,
      ),
      child: imageAsset == null
          ? const Icon(
              Icons.inventory_2_outlined,
              color: JuselColors.mutedForeground,
            )
          : null,
    );
  }
}

class _MovementMeta {
  final String title;
  final IconData badge;
  final Color badgeColor;
  final Color badgeIconColor;
  final bool isAddition;
  final int displayDelta;

  const _MovementMeta({
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.badgeIconColor,
    required this.isAddition,
    required this.displayDelta,
  });
}

String _filterLabelForType(String type) {
  switch (type) {
    case 'sale':
      return 'Sales';
    case 'stock_in':
      return 'Restocks';
    case 'production_output':
      return 'Production';
    case 'stock_out':
    case 'adjustment':
    case 'wastage':
    case 'return':
      return 'Adjustments';
    default:
      return 'Adjustments';
  }
}

Map<String, List<StockMovementsTableData>> _groupByDay(
  List<StockMovementsTableData> movements,
) {
  final Map<String, List<StockMovementsTableData>> grouped = {};
  for (final movement in movements) {
    final label = _dayLabel(movement.createdAt);
    grouped.putIfAbsent(label, () => []).add(movement);
  }
  return grouped;
}

String _dayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(date.year, date.month, date.day);

  if (dateOnly == today) return 'Today';
  if (dateOnly == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  }
  return DateFormat('MMM d, yyyy').format(date);
}

_MovementMeta _movementMeta(StockMovementsTableData movement) {
  final filterLabel = _filterLabelForType(movement.type);
  final absQuantity = movement.quantityUnits.abs();

  bool isAddition;
  IconData icon;
  Color badgeColor;
  Color badgeIconColor;
  String title;

  switch (movement.type) {
    case 'sale':
      isAddition = false;
      icon = Icons.shopping_cart_outlined;
      badgeColor = const Color(0xFFFFE4E6);
      badgeIconColor = JuselColors.destructive;
      title = 'Sale';
      break;
    case 'stock_in':
      isAddition = true;
      icon = Icons.inventory_outlined;
      badgeColor = const Color(0xFFE9FBE7);
      badgeIconColor = JuselColors.success;
      title = 'Restock';
      break;
    case 'production_output':
      isAddition = true;
      icon = Icons.inventory_2_outlined;
      badgeColor = const Color(0xFFE8F1FF);
      badgeIconColor = JuselColors.primary;
      title = 'Production';
      break;
    case 'stock_out':
      isAddition = false;
      icon = Icons.outbox_outlined;
      badgeColor = const Color(0xFFFFF1F2);
      badgeIconColor = JuselColors.destructive;
      title = 'Stock Out';
      break;
    case 'adjustment':
      isAddition = movement.quantityUnits >= 0;
      icon = Icons.tune;
      badgeColor = const Color(0xFFE8F1FF);
      badgeIconColor = const Color(0xFF6B7280);
      title = 'Adjustment';
      break;
    case 'wastage':
      isAddition = false;
      icon = Icons.delete_outline;
      badgeColor = const Color(0xFFFFEDE5);
      badgeIconColor = const Color(0xFFF97316);
      title = 'Wastage';
      break;
    case 'return':
      isAddition = true;
      icon = Icons.reply_outlined;
      badgeColor = const Color(0xFFE8F1FF);
      badgeIconColor = JuselColors.primary;
      title = 'Return';
      break;
    default:
      isAddition = movement.quantityUnits >= 0;
      icon = Icons.history;
      badgeColor = const Color(0xFFE5E7EB);
      badgeIconColor = JuselColors.mutedForeground;
      title = filterLabel;
      break;
  }

  if (movement.quantityUnits < 0) {
    isAddition = false;
  }

  final displayDelta = absQuantity;

  return _MovementMeta(
    title: title,
    badge: icon,
    badgeColor: badgeColor,
    badgeIconColor: badgeIconColor,
    isAddition: isAddition,
    displayDelta: displayDelta,
  );
}
