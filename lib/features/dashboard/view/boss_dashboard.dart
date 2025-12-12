import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/ui/components/quick_action_card.dart';
import 'package:jusel_app/features/account/view/account_screen.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_tab_provider.dart';
import 'package:jusel_app/features/production/view/batch_screen.dart';
import 'package:jusel_app/features/products/view/products_screen.dart';
import 'package:jusel_app/features/reports/view/reports_screen.dart';
import 'package:jusel_app/features/sales/view/sales_screen.dart';
import 'package:jusel_app/features/stock/view/restock_screen.dart';
import 'package:jusel_app/features/stock/view/stock_detail_screen.dart';
import 'package:jusel_app/core/database/app_database.dart';

class BossDashboard extends ConsumerStatefulWidget {
  const BossDashboard({super.key});

  @override
  ConsumerState<BossDashboard> createState() => _BossDashboardState();
}

class _BossDashboardState extends ConsumerState<BossDashboard> {
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      DashboardHome(onNavigateToTab: _setTab),
      const ProductsScreen(),
      const SalesScreen(),
      const RestockScreen(),
      const ReportsScreen(),
    ];
  }

  void _setTab(int index) {
    ref.read(dashboardTabProvider.notifier).setTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(dashboardTabProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          safePop(context, fallbackRoute: '/boss-dashboard');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: currentIndex, children: _pages),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => _setTab(i),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Stock',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHome extends ConsumerWidget {
  final void Function(int) onNavigateToTab;
  const DashboardHome({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardProvider);
    final lowStockAsync = ref.watch(lowStockProvider);

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
                _QuickActions(onNavigateToTab: onNavigateToTab),
                const SizedBox(height: 20),
                _OverviewGrid(metrics: metrics),
                const SizedBox(height: 20),
                _AlertsCard(lowStockAsync: lowStockAsync),
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

final lowStockProvider = FutureProvider.autoDispose<List<_LowStockItem>>((
  ref,
) async {
  final inventory = ref.read(inventoryServiceProvider);
  final products = await inventory.getLowStockProducts();

  final items = await Future.wait(
    products.map((p) async {
      final stock = await inventory.getCurrentStock(p.id);
      return _LowStockItem(product: p, stock: stock);
    }),
  );

  return items;
});

class _LowStockItem {
  final ProductsTableData product;
  final int stock;

  const _LowStockItem({required this.product, required this.stock});
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
                style: JuselTextStyles.headlineLarge(context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  color: JuselColors.foreground(context),
                ),
              ),
              Text(
                'Welcome back, Boss',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  fontSize: 18,
                  color: JuselColors.mutedForeground(context),
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
                color: JuselColors.primaryColor(context),
                borderRadius: BorderRadius.circular(500),
              ),
              child: Text(
                'Boss',
                style: TextStyle(
                  color: JuselColors.background(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: JuselSpacing.s6),
            InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                );
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: JuselColors.muted(context),
                child: Icon(
                  Icons.person,
                  size: 25,
                  color: JuselColors.mutedForeground(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final void Function(int) onNavigateToTab;
  const _QuickActions({required this.onNavigateToTab});

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
                onTap: () => onNavigateToTab(2),
                gradientColors: [
                  JuselColors.primaryColor(context).withOpacity(0.16),
                  JuselColors.primaryColor(context).withOpacity(0.08),
                ],
                iconColor: JuselColors.primaryColor(context),
              ),
              const SizedBox(width: JuselSpacing.s12),
              QuickActionCard(
                icon: Icons.inventory_2_outlined,
                label: 'Restock',
                onTap: () => onNavigateToTab(3),
                gradientColors: [
                  JuselColors.secondaryColor(context).withOpacity(0.16),
                  JuselColors.secondaryColor(context).withOpacity(0.10),
                ],
                iconColor: JuselColors.secondaryColor(context),
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
                  JuselColors.accentColor(context).withOpacity(0.16),
                  JuselColors.accentColor(context).withOpacity(0.10),
                ],
                iconColor: JuselColors.accentColor(context),
              ),
              const SizedBox(width: JuselSpacing.s12),
              QuickActionCard(
                icon: Icons.sell_outlined,
                label: 'Product',
                onTap: () => onNavigateToTab(1),
                gradientColors: [
                  JuselColors.mutedForeground(context).withOpacity(0.18),
                  JuselColors.mutedForeground(context).withOpacity(0.12),
                ],
                iconColor: JuselColors.foreground(context),
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
                  color: JuselColors.muted(context),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: JuselSpacing.s8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: JuselColors.primaryColor(
                    context,
                  ).withValues(alpha: 0.28),
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
        deltaPositive: false,
        iconColor: JuselColors.primaryColor(context),
      ),
      _OverviewItem(
        title: 'Profit',
        icon: Icons.access_time,
        value: _formatCurrency(metrics.profitTotal),
        delta: null,
        deltaPositive: false,
        valueColor: JuselColors.primaryColor(context),
        iconColor: JuselColors.primaryColor(context),
      ),
      _OverviewItem(
        title: 'Inv. Value',
        icon: Icons.all_inbox_outlined,
        value: _formatCurrency(metrics.inventoryValue),
        delta: null,
        deltaPositive: false,
        iconColor: JuselColors.successColor(context),
      ),
      _OverviewItem(
        title: 'Prod. Value',
        icon: Icons.show_chart_outlined,
        value: _formatCurrency(metrics.productionValue),
        delta: null,
        deltaPositive: false,
        iconColor: JuselColors.warningColor(context),
      ),
      _OverviewItem(
        title: 'Low Stock',
        icon: Icons.error_outline,
        value: metrics.lowStockCount.toString(),
        delta: 'Items need attention',
        deltaPositive: false,
        showDeltaIcon: false,
        background: JuselColors.warningColor(context).withOpacity(0.12),
        valueColor: JuselColors.warningColor(context),
        titleColor: JuselColors.warningColor(context),
        iconColor: JuselColors.warningColor(context),
      ),
      _OverviewItem(
        title: 'Pending Sync',
        icon: Icons.sync_disabled_outlined,
        value: metrics.pendingSyncCount.toString(),
        delta: 'All synced',
        deltaPositive: false,
        showDeltaIcon: false,
        iconColor: JuselColors.mutedForeground(context),
        deltaColor: JuselColors.mutedForeground(context),
        titleColor: JuselColors.mutedForeground(context),
        valueColor: JuselColors.foreground(context),
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
              style: JuselTextStyles.headlineMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: periodOptions.first,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: JuselColors.primaryColor(context),
                ),
                items: periodOptions
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          p,
                          style: JuselTextStyles.bodyMedium(context).copyWith(
                            color: JuselColors.primaryColor(context),
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
            final isCompact = constraints.maxWidth < 540;
            final crossAxisCount = 2;
            final aspect = isCompact ? 1.38 : 1.6;
            final spacing = isCompact ? 10.0 : 12.0;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: aspect,
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
    this.valueColor,
    this.background,
    this.titleColor,
    this.iconColor,
    this.showDeltaIcon = true,
    this.deltaColor,
    required this.deltaPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: background ?? JuselColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: JuselColors.border(context).withValues(alpha: 0.9),
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
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  color: titleColor ?? JuselColors.foreground(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Icon(
                icon,
                size: 27,
                color:
                    iconColor ??
                    titleColor ??
                    JuselColors.mutedForeground(context),
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s12),
          Text(
            value,
            style: JuselTextStyles.headlineLarge(context).copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? JuselColors.foreground(context),
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
                        ? JuselColors.primaryColor(context)
                        : JuselColors.destructiveColor(context),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  delta!,
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color:
                        deltaColor ??
                        (deltaPositive
                            ? JuselColors.primaryColor(context)
                            : JuselColors.destructiveColor(context)),
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
  final AsyncValue<List<_LowStockItem>> lowStockAsync;
  const _AlertsCard({required this.lowStockAsync});

  @override
  Widget build(BuildContext context) {
    final alertColor = JuselColors.warningColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alerts',
          style: JuselTextStyles.headlineMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: JuselSpacing.s8),
        lowStockAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            'Failed to load alerts: $e',
            style: JuselTextStyles.bodySmall(context).copyWith(
              color: JuselColors.destructiveColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(JuselSpacing.s12),
                decoration: BoxDecoration(
                  color: JuselColors.card(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: JuselColors.border(context)),
                ),
                child: Text(
                  'No low stock alerts.',
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.mutedForeground(context),
                  ),
                ),
              );
            }

            return Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: JuselSpacing.s8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StockDetailScreen(productId: item.product.id),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(JuselSpacing.s16),
                            decoration: BoxDecoration(
                              color: alertColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: alertColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: alertColor,
                                ),
                                const SizedBox(width: JuselSpacing.s12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Low stock: ${item.product.name}',
                                        style:
                                            JuselTextStyles.bodyMedium(
                                              context,
                                            ).copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: alertColor,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Only ${item.stock} units remaining. Restock advised.',
                                        style: JuselTextStyles.bodySmall(
                                          context,
                                        ).copyWith(color: alertColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: alertColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
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
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: JuselColors.border(context).withValues(alpha: 0.9),
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
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: JuselColors.foreground(context),
                ),
              ),
              Text(
                'Last 7 days',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s12),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _SalesTrendPainter(
                values: values,
                primaryColor: JuselColors.primaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesTrendPainter extends CustomPainter {
  final List<double> values;
  final Color primaryColor;
  _SalesTrendPainter({required this.values, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = primaryColor
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
          color: JuselColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: JuselColors.border(context).withValues(alpha: 0.9),
            width: 0.5,
          ),
        ),
        child: Text(
          'Top Products',
          style: JuselTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground(context),
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
                ? JuselColors.accentColor(context)
                : JuselColors.primaryColor(context),
          ),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: JuselColors.border(context).withValues(alpha: 0.9),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Products',
            style: JuselTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w700,
              color: JuselColors.foreground(context),
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
              style: JuselTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: JuselColors.foreground(context),
              ),
            ),
            Text(
              item.value,
              style: JuselTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: JuselColors.mutedForeground(context),
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
            backgroundColor: JuselColors.muted(context),
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
