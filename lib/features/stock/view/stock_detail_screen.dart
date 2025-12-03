import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/stock/view/restock_screen.dart';

class StockDetailScreen extends StatelessWidget {
  final String? productId;
  final String productName;
  final String category;
  final int stockUnits;
  final double unitCost;

  const StockDetailScreen({
    super.key,
    this.productId,
    required this.productName,
    required this.category,
    required this.stockUnits,
    required this.unitCost,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Stock Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                category: category,
                productName: productName,
                stockUnits: stockUnits,
                unitCost: unitCost,
              ),
              const SizedBox(height: JuselSpacing.s16),
              const _AlertCard(),
              const SizedBox(height: JuselSpacing.s16),
              const _TrendCard(),
              const SizedBox(height: JuselSpacing.s16),
              const _RecentActivity(),
              const SizedBox(height: JuselSpacing.s16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestockScreen(
                        productId: productId,
                        productName: productName,
                        category: category,
                        currentStock: stockUnits,
                      ),
                    ),
                  );
                },
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
                child: const Text(
                  'Restock Product',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(height: JuselSpacing.s12),
              _GhostButton(label: 'Add to Purchase List', onTap: () {}),
              const SizedBox(height: JuselSpacing.s12),
              _LinkTile(label: 'View Production Batches', onTap: () {}),
              _LinkTile(label: 'View All Movements', onTap: () {}),
              _LinkTile(label: 'View Product Details', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String category;
  final String productName;
  final int stockUnits;
  final double unitCost;

  const _HeaderCard({
    required this.category,
    required this.productName,
    required this.stockUnits,
    required this.unitCost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: JuselSpacing.s12,
                  vertical: JuselSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: JuselTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: JuselColors.mutedForeground,
                  ),
                ),
              ),
              const SizedBox(width: JuselSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: JuselSpacing.s12,
                  vertical: JuselSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Low Stock',
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s8),
          Text(
            productName,
            style: JuselTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: JuselSpacing.s6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$stockUnits units',
                style: JuselTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: JuselSpacing.s12,
                  vertical: JuselSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: JuselColors.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Cost: GHS ${unitCost.toStringAsFixed(2)} / unit',
                  style: JuselTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: JuselColors.foreground,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF8E7C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),
              const SizedBox(width: JuselSpacing.s8),
              Expanded(
                child: Text(
                  'Stock level is below the minimum threshold of 10 units.',
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s6),
          Text(
            'Recommended reorder: 50 units',
            style: JuselTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: JuselSpacing.s12),
          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFFB45309), size: 18),
              const SizedBox(width: JuselSpacing.s6),
              Text(
                'Estimated days until out-of-stock:',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: const Color(0xFFB45309),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: JuselSpacing.s6),
              const Text(
                '~2.5 days',
                style: TextStyle(
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Trend (Last 7 Days)',
          style: JuselTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(JuselSpacing.s12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 120,
            child: CustomPaint(painter: _TrendPainter()),
          ),
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFA500)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = [
      Offset(10, size.height * 0.8),
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.45, size.height * 0.55),
      Offset(size.width * 0.65, size.height * 0.4),
      Offset(size.width * 0.78, size.height * 0.6),
      Offset(size.width * 0.9, size.height * 0.45),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    final items = [
      _Activity('Sale #1024', 'Today, 10:30 AM', -2),
      _Activity('Sale #1021', 'Yesterday, 4:15 PM', -3),
      _Activity('Manual Adjustment', 'Mon, 9:00 AM', -1),
      _Activity('Restock', 'Last Week', 20),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: JuselTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: JuselColors.border),
          ),
          child: Column(
            children: items
                .map(
                  (item) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: JuselSpacing.s12,
                          vertical: JuselSpacing.s16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: JuselTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: JuselSpacing.s4),
                                Text(
                                  item.subtitle,
                                  style: JuselTextStyles.bodySmall.copyWith(
                                    color: JuselColors.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              (item.delta > 0 ? '+' : '') +
                                  item.delta.toString(),
                              style: JuselTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: item.delta >= 0
                                    ? JuselColors.success
                                    : JuselColors.destructive,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item != items.last)
                        const Divider(height: 1, color: JuselColors.border),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _Activity {
  final String title;
  final String subtitle;
  final int delta;
  _Activity(this.title, this.subtitle, this.delta);
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: JuselColors.border),
        backgroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: JuselColors.foreground,
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LinkTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: JuselSpacing.s8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: JuselColors.border),
      ),
      child: ListTile(
        title: Text(
          label,
          style: JuselTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: JuselColors.mutedForeground,
        ),
        onTap: onTap,
      ),
    );
  }
}
