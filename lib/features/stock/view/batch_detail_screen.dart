import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class BatchDetailScreen extends StatelessWidget {
  final String batchCode;
  final String productName;
  final String badgeLabel;
  final DateTime producedAt;
  final String supplier;
  final int producedUnits;
  final int stockAdded;
  final double totalCost;
  final double unitCost;
  final double unitCostChangePercent;
  final double estimatedRevenue;
  final double estimatedMarginPercent;
  final Map<String, double> costBreakdown;
  final String notes;
  final String relatedMovementLabel;
  final int relatedMovementDelta;

  const BatchDetailScreen({
    super.key,
    required this.batchCode,
    required this.productName,
    required this.badgeLabel,
    required this.producedAt,
    required this.supplier,
    required this.producedUnits,
    required this.stockAdded,
    required this.totalCost,
    required this.unitCost,
    required this.unitCostChangePercent,
    required this.estimatedRevenue,
    required this.estimatedMarginPercent,
    required this.costBreakdown,
    required this.notes,
    required this.relatedMovementLabel,
    required this.relatedMovementDelta,
  });

  @override
  Widget build(BuildContext context) {
    final hour12 = producedAt.hour > 12
        ? producedAt.hour - 12
        : (producedAt.hour == 0 ? 12 : producedAt.hour);
    final period = producedAt.hour >= 12 ? 'PM' : 'AM';
    final dateString =
        '${_monthLabel(producedAt.month)} ${producedAt.day}, ${producedAt.year} • ${_two(hour12)}:${_two(producedAt.minute)} $period';

    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: JuselColors.background,
        shape: const Border(bottom: BorderSide(color: JuselColors.border)),
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
          'Batch Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeLabel.toUpperCase(),
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                batchCode,
                style: JuselTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: JuselColors.mutedForeground,
                  ),
                  const SizedBox(width: JuselSpacing.s6),
                  Text(
                    dateString,
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: JuselColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s8),
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: JuselColors.mutedForeground,
                  ),
                  const SizedBox(width: JuselSpacing.s6),
                  Text(
                    'Supplied by:',
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: JuselColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: JuselSpacing.s6),
                  Flexible(
                    child: Text(
                      supplier,
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s16),
              _StatGrid(
                items: [
                  _StatItem(
                    label: 'Produced',
                    value: '$producedUnits units',
                    valueColor: JuselColors.primary,
                  ),
                  _StatItem(
                    label: 'Stock Add',
                    value: '+$stockAdded',
                    valueColor: JuselColors.success,
                  ),
                  _StatItem(
                    label: 'Total Cost',
                    value: 'GHS ${totalCost.toStringAsFixed(2)}',
                    bold: true,
                  ),
                  _StatItem(
                    label: 'Unit Cost',
                    value: 'GHS ${unitCost.toStringAsFixed(2)}',
                    helper: '${unitCostChangePercent.toStringAsFixed(0)}%',
                    helperColor: JuselColors.success,
                    showArrow: true,
                  ),
                  _StatItem(
                    label: 'Est. Revenue',
                    value: 'GHS ${estimatedRevenue.toStringAsFixed(2)}',
                    bold: true,
                  ),
                  _StatItem(
                    label: 'Est. Margin',
                    value: '${estimatedMarginPercent.toStringAsFixed(1)}%',
                    valueColor: JuselColors.success,
                    bold: true,
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s16),
              Text(
                'COST BREAKDOWN',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: JuselColors.border),
                ),
                child: Column(
                  children: [
                    ...costBreakdown.entries.map(
                      (entry) => Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: JuselSpacing.s16,
                              vertical: JuselSpacing.s12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: JuselTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'GHS ${entry.value.toStringAsFixed(2)}',
                                  style: JuselTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (entry.key != costBreakdown.keys.last)
                            const Divider(height: 1, color: JuselColors.border),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: JuselColors.border),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: JuselColors.primary,
                      ),
                      label: const Text(
                        'View Full Breakdown',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: JuselColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: JuselSpacing.s16),
              Text(
                'NOTES',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(JuselSpacing.s12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: JuselColors.border),
                ),
                child: Text(
                  notes,
                  style: JuselTextStyles.bodyMedium.copyWith(
                    color: JuselColors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: JuselSpacing.s16),
              Text(
                'RELATED MOVEMENT',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    // TODO: Navigate to movement detail
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: JuselColors.border),
                    ),
                    padding: const EdgeInsets.all(JuselSpacing.s12),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F0FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.swap_horiz,
                            color: JuselColors.primary,
                          ),
                        ),
                        const SizedBox(width: JuselSpacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                relatedMovementLabel,
                                style: JuselTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: JuselSpacing.s4),
                              Text(
                                'Stock Update • ${relatedMovementDelta > 0 ? '+' : ''}$relatedMovementDelta units',
                                style: JuselTextStyles.bodySmall.copyWith(
                                  color: JuselColors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: JuselColors.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: JuselSpacing.s20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(
                    'Edit Batch',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JuselColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthLabel(int month) {
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
    return months[(month - 1).clamp(0, 11)];
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

class _StatGrid extends StatelessWidget {
  final List<_StatItem> items;
  const _StatGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: JuselSpacing.s12,
      runSpacing: JuselSpacing.s12,
      children: items
          .map(
            (item) => SizedBox(
              width:
                  (MediaQuery.of(context).size.width -
                      16 * 2 -
                      JuselSpacing.s12) /
                  2,
              child: _StatCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final String? helper;
  final Color? valueColor;
  final Color? helperColor;
  final bool bold;
  final bool showArrow;

  const _StatItem({
    required this.label,
    required this.value,
    this.helper,
    this.valueColor,
    this.helperColor,
    this.bold = false,
    this.showArrow = false,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: JuselTextStyles.bodySmall.copyWith(
              color: JuselColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: JuselSpacing.s6),
          Text(
            item.value,
            style: JuselTextStyles.bodyMedium.copyWith(
              fontWeight: item.bold ? FontWeight.w800 : FontWeight.w700,
              color: item.valueColor ?? JuselColors.foreground,
            ),
          ),
          if (item.helper != null) ...[
            const SizedBox(height: JuselSpacing.s6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.showArrow)
                  Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: item.helperColor ?? JuselColors.success,
                  ),
                if (item.showArrow) const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: JuselSpacing.s8,
                    vertical: JuselSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9FBE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.helper!,
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: item.helperColor ?? JuselColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
