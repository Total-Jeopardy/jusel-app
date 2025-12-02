import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/stock/view/stock_history_screen.dart';

class RestockSuccessScreen extends StatelessWidget {
  final String productName;
  final String category;
  final String? imageAsset;
  final int unitsAdded;
  final int newTotalStock;
  final double costPerUnit;
  final double inventoryValueAdded;
  final String restockedBy;
  final DateTime restockedOn;

  const RestockSuccessScreen({
    super.key,
    required this.productName,
    required this.category,
    this.imageAsset,
    required this.unitsAdded,
    required this.newTotalStock,
    required this.costPerUnit,
    required this.inventoryValueAdded,
    required this.restockedBy,
    required this.restockedOn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuselColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: JuselSpacing.s20),
              _SummaryCard(
                productName: productName,
                category: category,
                imageAsset: imageAsset,
                unitsAdded: unitsAdded,
                newTotalStock: newTotalStock,
                costPerUnit: costPerUnit,
                inventoryValueAdded: inventoryValueAdded,
                restockedBy: restockedBy,
                restockedOn: restockedOn,
              ),
              const SizedBox(height: JuselSpacing.s20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JuselColors.primary,
                    foregroundColor: JuselColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Product',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: JuselSpacing.s12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StockHistoryScreen(
                          productName: productName,
                          currentStock: newTotalStock,
                          imageAsset: imageAsset,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: JuselColors.border),
                    foregroundColor: JuselColors.foreground,
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'View Stock Movements',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: JuselColors.foreground,
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
}

class _SummaryCard extends StatelessWidget {
  final String productName;
  final String category;
  final String? imageAsset;
  final int unitsAdded;
  final int newTotalStock;
  final double costPerUnit;
  final double inventoryValueAdded;
  final String restockedBy;
  final DateTime restockedOn;

  const _SummaryCard({
    required this.productName,
    required this.category,
    required this.imageAsset,
    required this.unitsAdded,
    required this.newTotalStock,
    required this.costPerUnit,
    required this.inventoryValueAdded,
    required this.restockedBy,
    required this.restockedOn,
  });

  @override
  Widget build(BuildContext context) {
    final dateString =
        '${_monthLabel(restockedOn.month)} ${restockedOn.day}, ${restockedOn.hour.toString().padLeft(2, '0')}:${restockedOn.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ProductThumbnail(imageAsset: imageAsset),
                const SizedBox(width: JuselSpacing.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: JuselTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s4),
                    Text(
                      category,
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
            _InfoRow(
              label: 'Units Added',
              value: '+$unitsAdded Units',
              valueColor: JuselColors.success,
              isBold: true,
            ),
            const _Divider(),
            _InfoRow(
              label: 'New Total Stock',
              value: '$newTotalStock Units',
              isBold: true,
            ),
            const _Divider(),
            _InfoRow(
              label: 'Cost per Unit',
              value: 'GHS ${costPerUnit.toStringAsFixed(2)}',
            ),
            _InfoRow(
              label: 'Inventory Value Added',
              value: 'GHS ${inventoryValueAdded.toStringAsFixed(2)}',
              isBold: true,
            ),
            const _Divider(),
            _InfoRow(
              label: 'Restocked By',
              value: restockedBy,
            ),
            _InfoRow(
              label: 'Restocked on',
              value: dateString,
              isBold: true,
            ),
          ],
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
      'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: JuselTextStyles.bodyMedium.copyWith(
              color: JuselColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: JuselTextStyles.bodyMedium.copyWith(
              color: valueColor ?? JuselColors.foreground,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: JuselSpacing.s4),
      child: Divider(
        height: 1,
        color: JuselColors.border,
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: JuselColors.muted,
        image: imageAsset != null
            ? DecorationImage(
                image: AssetImage(imageAsset!),
                fit: BoxFit.cover,
              )
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
