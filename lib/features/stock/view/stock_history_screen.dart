import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/stock/view/batch_detail_screen.dart';

class StockHistoryScreen extends StatefulWidget {
  final String productName;
  final int currentStock;
  final String? imageAsset;

  const StockHistoryScreen({
    super.key,
    required this.productName,
    required this.currentStock,
    this.imageAsset,
  });

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final movements = _sampleMovements()
        .where((m) => _selectedFilter == 'All' || m.type == _selectedFilter)
        .toList();
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
              onPressed: () => Navigator.pop(context),
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
              _DaySection(
                title: 'Today',
                items: movements
                    .where((m) => m.dayGroup == 'today')
                    .map(_MovementCard.new)
                    .toList(),
              ),
              const SizedBox(height: JuselSpacing.s12),
              _DaySection(
                title: 'Yesterday',
                items: movements
                    .where((m) => m.dayGroup == 'yesterday')
                    .map(_MovementCard.new)
                    .toList(),
              ),
              const SizedBox(height: JuselSpacing.s12),
              _DaySection(
                title: 'Last Week',
                items: movements
                    .where((m) => m.dayGroup == 'last_week')
                    .map(_MovementCard.new)
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Movement> _sampleMovements() {
    // Static sample data to mirror the design; hook to real data later.
    return const [
      _Movement(
        title: 'Sale #1024',
        subtitle: '10:30 AM • Apprentice',
        type: 'Sales',
        badge: Icons.shopping_cart_outlined,
        badgeColor: Color(0xFFFFE4E6),
        badgeIconColor: JuselColors.destructive,
        delta: -2,
        unitLabel: 'units',
        dayGroup: 'today',
      ),
      _Movement(
        title: 'Production',
        subtitle: '08:30 AM • Boss',
        type: 'Production',
        badge: Icons.inventory_2_outlined,
        badgeColor: Color(0xFFE8F1FF),
        badgeIconColor: JuselColors.primary,
        delta: 20,
        helper: 'Batch #104',
        trailingHelper: '\$0.73 / unit',
        dayGroup: 'today',
        batchCode: 'Batch #104',
      ),
      _Movement(
        title: 'Restock',
        subtitle: '08:10 AM • Boss',
        type: 'Restocks',
        badge: Icons.inventory_outlined,
        badgeColor: Color(0xFFE9FBE7),
        badgeIconColor: JuselColors.success,
        delta: 60,
        helper: 'Added new stock',
        dayGroup: 'today',
      ),
      _Movement(
        title: 'Wastage',
        subtitle: '06:15 PM • Boss',
        type: 'Adjustments',
        badge: Icons.delete_outline,
        badgeColor: Color(0xFFFFEDE5),
        badgeIconColor: const Color(0xFFF97316),
        delta: -5,
        helper: 'Spilled during transfer',
        dayGroup: 'yesterday',
      ),
      _Movement(
        title: 'Sale #1021',
        subtitle: '02:30 PM • Apprentice',
        type: 'Sales',
        badge: Icons.shopping_cart_outlined,
        badgeColor: Color(0xFFFFE4E6),
        badgeIconColor: JuselColors.destructive,
        delta: -8,
        dayGroup: 'yesterday',
      ),
      _Movement(
        title: 'Inventory Check',
        subtitle: 'Mon, 9:00 AM • Boss',
        type: 'Adjustments',
        badge: Icons.tune,
        badgeColor: Color(0xFFE8F1FF),
        badgeIconColor: const Color(0xFF6B7280),
        delta: 2,
        helper: 'Found extra stock',
        dayGroup: 'last_week',
      ),
      _Movement(
        title: 'Production',
        subtitle: 'Oct 12 • Boss',
        type: 'Production',
        badge: Icons.inventory_2_outlined,
        badgeColor: Color(0xFFE8F1FF),
        badgeIconColor: JuselColors.primary,
        delta: 50,
        helper: 'Batch #103',
        trailingHelper: '\$0.64 / unit',
        dayGroup: 'last_week',
        batchCode: 'Batch #103',
      ),
    ];
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
  final _Movement movement;
  const _MovementCard(this.movement);

  void _openBatch(BuildContext context) {
    if (movement.batchCode == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BatchDetailScreen(
          batchCode: movement.batchCode!,
          productName: 'Homemade Lemonade',
          badgeLabel: 'Local Drink',
          producedAt: DateTime(2023, 10, 12, 8, 30),
          supplier: 'Fresh Farms Ltd',
          producedUnits: 20,
          stockAdded: 20,
          totalCost: 14.60,
          unitCost: 0.73,
          unitCostChangePercent: -4,
          estimatedRevenue: 29.20,
          estimatedMarginPercent: 50.0,
          costBreakdown: const {
            'Ingredients': 10.00,
            'Packaging': 2.00,
            'Labor': 1.60,
            'Gas': 1.00,
          },
          notes:
              'Production ran smoothly. New lemon supplier tested for this batch, acidity is slightly higher.',
          relatedMovementLabel: 'Movement #542',
          relatedMovementDelta: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deltaColor = movement.delta >= 0
        ? JuselColors.success
        : JuselColors.destructive;
    final deltaPrefix = movement.delta > 0 ? '+' : '';
    final card = Container(
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
              color: movement.badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(movement.badge, color: movement.badgeIconColor),
          ),
          const SizedBox(width: JuselSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.title,
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  movement.subtitle,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (movement.helper != null) ...[
                  const SizedBox(height: JuselSpacing.s6),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: movement.batchCode != null
                        ? () => _openBatch(context)
                        : null,
                    child: Container(
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
                        movement.helper!,
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: movement.batchCode != null
                              ? JuselColors.primary
                              : JuselColors.foreground,
                          fontWeight: FontWeight.w700,
                          decoration: movement.batchCode != null
                              ? TextDecoration.underline
                              : null,
                        ),
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
                '$deltaPrefix${movement.delta}',
                style: JuselTextStyles.bodyMedium.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (movement.trailingHelper != null) ...[
                const SizedBox(height: JuselSpacing.s6),
                Text(
                  movement.trailingHelper!,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
    if (movement.batchCode != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openBatch(context),
        child: card,
      );
    }
    return card;
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

class _Movement {
  final String title;
  final String subtitle;
  final String type;
  final IconData badge;
  final Color badgeColor;
  final Color badgeIconColor;
  final int delta;
  final String? helper;
  final String? trailingHelper;
  final String dayGroup;
  final String unitLabel;
  final String? batchCode;

  const _Movement({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.badge,
    required this.badgeColor,
    required this.badgeIconColor,
    required this.delta,
    this.helper,
    this.trailingHelper,
    required this.dayGroup,
    this.unitLabel = 'Units',
    this.batchCode,
  });
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
