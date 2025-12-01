import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/ui/components/quick_action_card.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:jusel_app/features/notifications/view/notifications_screen.dart';
import 'package:jusel_app/features/production/view/batch_screen.dart';
import 'package:jusel_app/features/products/view/products_screen.dart';
import 'package:jusel_app/features/sales/view/sales_screen.dart';
import 'package:jusel_app/features/stock/view/restock_screen.dart';

class BossDashboard extends StatefulWidget {
  const BossDashboard({super.key});

  @override
  State<BossDashboard> createState() => _BossDashboardState();
}

class _BossDashboardState extends State<BossDashboard> {
  int _currentIndex = 0;

  late final _pages = <Widget>[const DashboardHome()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Sales',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stock'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: metricsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error loading dashboard: $e'),
          ),
          data: (metrics) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                const SizedBox(height: 20),
                const _QuickActions(),
                const SizedBox(height: 20),
                _OverviewGrid(metrics: metrics),
                const SizedBox(height: 20),
                const _AlertsCard(),
                const SizedBox(height: 16),
                _TrendCard(values: metrics.trendValues),
                const SizedBox(height: 16),
                _TopProductsCard(topProducts: metrics.topProducts),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Define _Header, _QuickActions, _OverviewGrid, _AlertsCard, _TrendCard, _TopProductsCard,
// and PlaceholderScreen with simple layouts, using JuselTextStyles and JuselCard.

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: JuselTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  color: JuselColors.foreground,
                ),
              ),
              Text(
                'Welcome back, Boss',
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontSize: 18,
                  color: JuselColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: JuselSpacing.s20,
                vertical: JuselSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: JuselColors.primary,
                borderRadius: BorderRadius.circular(500),
              ),
              child: const Text(
                'Boss',
                style: TextStyle(
                  color: JuselColors.background,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: JuselSpacing.s6),
            const CircleAvatar(
              radius: 25,
              backgroundColor: JuselColors.muted,
              child: Icon(
                Icons.person,
                size: 25,
                color: JuselColors.mutedForeground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: JuselSpacing.s8),
          child: Row(
            children: [
              QuickActionCard(
                icon: Icons.add,
                label: 'Sale',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesScreen()),
                ),
                gradientColors: [
                  const Color(0xFF1F6BFF).withOpacity(0.16),
                  const Color(0xFF1F6BFF).withOpacity(0.08),
                ],
                iconColor: const Color(0xFF1F6BFF),
              ),
              const SizedBox(width: JuselSpacing.s12),
              QuickActionCard(
                icon: Icons.inventory_2_outlined,
                label: 'Restock',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RestockScreen()),
                ),
                gradientColors: [
                  const Color(0xFF22D3EE).withOpacity(0.16),
                  const Color(0xFF34D399).withOpacity(0.10),
                ],
                iconColor: const Color(0xFF0EA5E9),
              ),
              const SizedBox(width: JuselSpacing.s12),
              QuickActionCard(
                icon: Icons.science_outlined,
                label: 'Batch',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BatchScreen()),
                ),
                gradientColors: [
                  const Color(0xFF7C5CFF).withOpacity(0.16),
                  const Color(0xFF38BDF8).withOpacity(0.10),
                ],
                iconColor: const Color(0xFF7C5CFF),
              ),
              const SizedBox(width: JuselSpacing.s12),
              QuickActionCard(
                icon: Icons.sell_outlined,
                label: 'Product',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                ),
                gradientColors: [
                  const Color(0xFF94A3B8).withOpacity(0.18),
                  const Color(0xFFE2E8F0).withOpacity(0.12),
                ],
                iconColor: const Color(0xFF0F172A),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: JuselSpacing.s8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: JuselColors.muted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: JuselSpacing.s8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: JuselColors.primary.withOpacity(0.28),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  final DashboardMetrics metrics;
  const _OverviewGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final periodOptions = ['Today', 'This week', 'This month', 'This quarter'];
    final cards = [
      _OverviewItem(
        title: 'Sales',
        icon: Icons.attach_money,
        value: _formatCurrency(metrics.salesTotal),
        delta: null,
        iconColor: const Color(0xFF1F6BFF),
      ),
      _OverviewItem(
        title: 'Profit',
        icon: Icons.access_time,
        value: _formatCurrency(metrics.profitTotal),
        delta: null,
        valueColor: JuselColors.primary,
        iconColor: JuselColors.primary,
      ),
      _OverviewItem(
        title: 'Inv. Value',
        icon: Icons.all_inbox_outlined,
        value: _formatCurrency(metrics.inventoryValue),
        delta: null,
        iconColor: const Color(0xFF10B981),
      ),
      _OverviewItem(
        title: 'Prod. Value',
        icon: Icons.show_chart_outlined,
        value: _formatCurrency(metrics.productionValue),
        delta: null,
        iconColor: const Color(0xFFF59E0B),
      ),
      _OverviewItem(
        title: 'Low Stock',
        icon: Icons.error_outline,
        value: metrics.lowStockCount.toString(),
        delta: 'Items need attention',
        showDeltaIcon: false,
        background: const Color(0xFFFFF1F2),
        valueColor: const Color(0xFFDC2626),
        titleColor: const Color(0xFFDC2626),
        iconColor: const Color(0xFFDC2626),
      ),
      _OverviewItem(
        title: 'Pending Sync',
        icon: Icons.sync_disabled_outlined,
        value: metrics.pendingSyncCount.toString(),
        delta: 'All synced',
        showDeltaIcon: false,
        iconColor: JuselColors.mutedForeground,
        deltaColor: JuselColors.mutedForeground,
        titleColor: JuselColors.mutedForeground,
        valueColor: JuselColors.foreground,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overview',
              style: JuselTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: periodOptions.first,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: JuselColors.primary,
                ),
                items: periodOptions
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          p,
                          style: JuselTextStyles.bodyMedium.copyWith(
                            color: JuselColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: JuselSpacing.s12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final crossAxisCount = isNarrow ? 1 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isNarrow ? 2.2 : 1.3,
              ),
              itemBuilder: (_, index) => cards[index],
            );
          },
        ),
      ],
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String? delta;
  final bool deltaPositive;
  final Color? valueColor;
  final Color? background;
  final Color? titleColor;
  final Color? iconColor;
  final bool showDeltaIcon;
  final Color? deltaColor;

  const _OverviewItem({
    required this.title,
    required this.icon,
    required this.value,
    this.delta,
    this.deltaPositive = true,
    this.valueColor,
    this.background,
    this.titleColor,
    this.iconColor,
    this.showDeltaIcon = true,
    this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: JuselColors.border.withOpacity(0.9),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: JuselTextStyles.bodyMedium.copyWith(
                  color: titleColor ?? JuselColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(
                icon,
                size: 27,
                color: iconColor ?? titleColor ?? JuselColors.mutedForeground,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: JuselTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? JuselColors.foreground,
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (showDeltaIcon) ...[
                  Icon(
                    deltaPositive ? Icons.trending_up : Icons.trending_down,
                    size: 22,
                    color: deltaPositive
                        ? JuselColors.primary
                        : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  delta!,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color:
                        deltaColor ??
                        (deltaPositive
                            ? JuselColors.primary
                            : const Color(0xFFDC2626)),
                    fontWeight: FontWeight.w600,
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

class _AlertsCard extends StatelessWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context) {
    const alertColor = Color(0xFFB45309);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alerts',
          style: JuselTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(JuselSpacing.s16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4D6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: alertColor),
                  const SizedBox(width: JuselSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Low stock: Cola 500ml',
                          style: JuselTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: alertColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Only 4 units remaining. Restock advised.',
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: alertColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: alertColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  final List<double> values;
  const _TrendCard({required this.values});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: JuselColors.border.withOpacity(0.9),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales Trend',
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: JuselColors.foreground,
                ),
              ),
              Text(
                'Last 7 days',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s12),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(painter: _SalesTrendPainter(values: values)),
          ),
        ],
      ),
    );
  }
}

class _SalesTrendPainter extends CustomPainter {
  final List<double> values;
  _SalesTrendPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = JuselColors.primary.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = JuselColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final data = values.isEmpty ? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0] : values;
    final maxVal = data.fold<double>(0, (prev, el) => prev > el ? prev : el);
    final normalized = data
        .map((v) => maxVal == 0 ? 0.6 : 1 - (v / maxVal) * 0.7)
        .toList();

    final step = normalized.length > 1
        ? size.width / (normalized.length - 1)
        : size.width;
    final points = List<Offset>.generate(
      normalized.length,
      (i) => Offset(step * i, size.height * normalized[i]),
    );

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];
      final control1 = Offset(prev.dx + (current.dx - prev.dx) * 0.5, prev.dy);
      final control2 = Offset(
        prev.dx + (current.dx - prev.dx) * 0.5,
        current.dy,
      );
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        current.dx,
        current.dy,
      );
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(fillPath, bgPaint);

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopProductsCard extends StatelessWidget {
  final List<TopProductMetric> topProducts;
  const _TopProductsCard({required this.topProducts});

  @override
  Widget build(BuildContext context) {
    if (topProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: JuselColors.border.withOpacity(0.9),
            width: 0.5,
          ),
        ),
        child: Text(
          'Top Products',
          style: JuselTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground,
          ),
        ),
      );
    }

    final maxRevenue = topProducts
        .map((t) => t.revenue)
        .fold<double>(0, (prev, el) => prev > el ? prev : el);
    final items = topProducts
        .asMap()
        .entries
        .map(
          (entry) => _TopProduct(
            name: entry.value.name,
            value: _formatCurrency(entry.value.revenue),
            progress: maxRevenue == 0 ? 0 : entry.value.revenue / maxRevenue,
            color: entry.key == 2
                ? const Color(0xFF14B8A6)
                : const Color(0xFF2563EB),
          ),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: JuselColors.border.withOpacity(0.9),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Products',
            style: JuselTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: JuselColors.foreground,
            ),
          ),
          const SizedBox(height: JuselSpacing.s12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: JuselSpacing.s12),
              child: _TopProductRow(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProduct {
  final String name;
  final String value;
  final double progress;
  final Color color;

  _TopProduct({
    required this.name,
    required this.value,
    required this.progress,
    required this.color,
  });
}

class _TopProductRow extends StatelessWidget {
  final _TopProduct item;
  const _TopProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name,
              style: JuselTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: JuselColors.foreground,
              ),
            ),
            Text(
              item.value,
              style: JuselTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: JuselColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: JuselSpacing.s6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: item.progress,
            backgroundColor: JuselColors.muted,
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
          ),
        ),
      ],
    );
  }
}

String _formatCurrency(double value) {
  // Simple formatter with commas, no decimals
  return 'GHS ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}
