import 'package:flutter/material.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/utils/theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductsTableData product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final sellingPrice = product.currentSellingPrice;
    final costPrice = product.currentCostPrice;
    final margin = sellingPrice == 0
        ? 0
        : ((sellingPrice - costPrice) / sellingPrice) * 100;

    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Product Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(product: product),
            const SizedBox(height: JuselSpacing.s12),
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Selling Price',
                  value: 'GHS ${sellingPrice.toStringAsFixed(2)}',
                  valueColor: JuselColors.primary,
                  bold: true,
                  dense: true,
                ),
                _DividerRow(),
                _InfoRow(
                  label: 'Cost Price',
                  value: 'GHS ${costPrice.toStringAsFixed(2)}',
                  helper: 'Margin: ${margin.toStringAsFixed(0)}%',
                  valueBold: true,
                  helperUnderValue: true,
                  dense: true,
                ),
                _DividerRow(),
                _InfoRow(
                  label: 'Units per Pack',
                  value: product.unitsPerPack?.toString() ?? '--',
                  valueBold: true,
                  helperUnderValue: true,
                  dense: true,
                ),
                _DividerRow(),
                const _SectionTitle('Price History (Last 6 Months)'),
                const SizedBox(height: JuselSpacing.s12),
                _MonthsRow(),
              ],
            ),
            const SizedBox(height: JuselSpacing.s12),
            _InfoCard(
              children: [
                const _SectionTitle('Stock Alerts'),
                _DividerRow(),
                const _InfoRow(label: 'Low stock threshold', value: '10'),
                _DividerRow(),
                const _InfoRow(
                  label: 'Reorder recommendation',
                  value: 'Buy 24 units',
                  valueColor: JuselColors.primary,
                  bold: true,
                ),
                _DividerRow(),
                const _InfoRow(
                  label: 'Days until out-of-stock',
                  value: '~2 days',
                  valueColor: Color(0xFFFB923C),
                  bold: true,
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s12),
            _InfoCard(
              children: [
                const _InfoRow(
                  label: 'Status',
                  value: 'Active',
                  valueColor: JuselColors.success,
                  showDot: true,
                  dense: true,
                ),
                _DividerRow(),
                const Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Last Restock',
                        value: 'Oct 24, 2023',
                      ),
                    ),
                    SizedBox(width: JuselSpacing.s12),
                    Expanded(
                      child: _StatTile(
                        label: 'Total Sold',
                        value: '1,240 units',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: JuselSpacing.s16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: JuselColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.white),
                    SizedBox(width: JuselSpacing.s8),
                    Text(
                      'Restock Product',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: JuselSpacing.s12),
            Column(
              children: [
                _NavTile(label: 'Edit Product', onTap: () {}),
                const SizedBox(height: JuselSpacing.s12),
                _NavTile(label: 'View Stock Movements', onTap: () {}),
              ],
            ),
            const SizedBox(height: JuselSpacing.s12),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ProductsTableData product;
  const _HeaderCard({required this.product});

  String _statusLabel() {
    final count = product.currentStockQty;
    final status = product.status.toLowerCase();
    if (status.contains('out')) return 'Out of Stock';
    if (status.contains('low')) return 'Low Stock ($count)';
    return 'In Stock';
  }

  Color _statusColor() {
    final status = product.status.toLowerCase();
    if (status.contains('out')) return const Color(0xFFEF4444);
    if (status.contains('low')) return const Color(0xFFF59E0B);
    return const Color(0xFF16A34A);
  }

  Color _statusBg() {
    final status = product.status.toLowerCase();
    if (status.contains('out')) return const Color(0xFFFFF1F2);
    if (status.contains('low')) return const Color(0xFFFFF7E6);
    return const Color(0xFFE9F8EF);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF1F5F9),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const Icon(
                Icons.image_outlined,
                color: JuselColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: JuselSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusPill(
                  label: _statusLabel(),
                  color: _statusColor(),
                  background: _statusBg(),
                ),
                const SizedBox(height: JuselSpacing.s6),
                Text(
                  product.name,
                  style: JuselTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  'Category: ${product.category}',
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? helper;
  final Color? valueColor;
  final bool bold;
  final bool showDot;
  final bool dense;
  final bool valueBold;
  final bool helperUnderValue;

  const _InfoRow({
    required this.label,
    required this.value,
    this.helper,
    this.valueColor,
    this.bold = false,
    this.showDot = false,
    this.dense = false,
    this.valueBold = false,
    this.helperUnderValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final vertical = dense ? JuselSpacing.s8 : JuselSpacing.s12;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                if (helper != null && !helperUnderValue)
                  Text(
                    helper!,
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: JuselColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (showDot) ...[
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: JuselSpacing.s6),
              decoration: const BoxDecoration(
                color: JuselColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: (bold || valueBold)
                      ? FontWeight.w800
                      : FontWeight.w700,
                  color: valueColor ?? JuselColors.foreground,
                ),
              ),
              if (helper != null && helperUnderValue)
                Text(
                  helper!,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DividerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 16, color: Color(0xFFE5E7EB), thickness: 1);
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: JuselSpacing.s6),
      child: Text(
        text,
        style: JuselTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: JuselColors.foreground,
        ),
      ),
    );
  }
}

class _MonthsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const months = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: months
          .map(
            (m) => Text(
              m,
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: JuselSpacing.s16,
            vertical: JuselSpacing.s16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground,
                    fontSize: 15,
                  ),
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
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: JuselTextStyles.bodySmall.copyWith(
              color: JuselColors.mutedForeground,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: JuselSpacing.s4),
          Text(
            value,
            style: JuselTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: JuselColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
