import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_tab_provider.dart';
import 'package:jusel_app/features/products/view/products_screen.dart';
import 'package:jusel_app/features/sales/view/sales_screen.dart';
import 'package:jusel_app/features/stock/view/stock_detail_screen.dart';

final apprenticeLowStockProvider =
    FutureProvider.autoDispose<List<_LowStockItem>>((ref) async {
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

class ApprenticeDashboard extends ConsumerStatefulWidget {
  const ApprenticeDashboard({super.key});

  @override
  ConsumerState<ApprenticeDashboard> createState() => _ApprenticeDashboardState();
}

class _ApprenticeDashboardState extends ConsumerState<ApprenticeDashboard> {
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _DashboardHome(onNavigateToTab: _setTab),
      const ProductsScreen(),
      const SalesScreen(),
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
          safePop(context, fallbackRoute: '/apprentice-dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: JuselColors.background(context),
        body: SafeArea(
          child: IndexedStack(index: currentIndex, children: _pages),
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: currentIndex,
          onTap: _setTab,
        ),
      ),
    );

  }

}

class _DashboardHome extends ConsumerWidget {
  final void Function(int) onNavigateToTab;

  const _DashboardHome({required this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockAsync = ref.watch(apprenticeLowStockProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: JuselSpacing.s16),
          _NewSaleCard(onNavigateToTab),
          const SizedBox(height: JuselSpacing.s16),
          _SavedSaleCard(onNavigateToTab),
          const SizedBox(height: JuselSpacing.s16),
          _AlertCard(lowStockAsync: lowStockAsync),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AsyncValue<List<_LowStockItem>> lowStockAsync;

  const _AlertCard({required this.lowStockAsync});

  @override

  Widget build(BuildContext context) {

    final alertColor = JuselColors.warningColor(context);

    return lowStockAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(JuselSpacing.s12),
        decoration: BoxDecoration(
          color: JuselColors.warningColor(context).withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: JuselColors.warningColor(context).withOpacity(0.3)),
        ),
        child: Text(
          'Failed to load alerts: $e',
          style: JuselTextStyles.bodySmall(context).copyWith(
            color: JuselColors.destructiveColor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuselSpacing.s12),
            decoration: BoxDecoration(
              color: JuselColors.card(context),
              borderRadius: BorderRadius.circular(14),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StockDetailScreen(productId: item.product.id),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: JuselSpacing.s16,
                          vertical: JuselSpacing.s16,
                        ),
                        decoration: BoxDecoration(
                          color: JuselColors.warningColor(context).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: JuselColors.warningColor(context).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: alertColor),
                            const SizedBox(width: JuselSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Low stock: ${item.product.name}',
                                    style:
                                        JuselTextStyles.bodyMedium(context).copyWith(
                                      color: alertColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Only ${item.stock} units remaining.',
                                    style: JuselTextStyles.bodySmall(context).copyWith(
                                      color: alertColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
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
    );

  }

}



class _NewSaleCard extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const _NewSaleCard(this.onNavigateToTab);

  @override

  Widget build(BuildContext context) {

    return ClipRRect(

      borderRadius: BorderRadius.circular(16),

      child: Stack(

        children: [

          Container(

            width: double.infinity,

            height: 170,

            decoration: BoxDecoration(

              gradient: LinearGradient(

                colors: [JuselColors.primaryColor(context), JuselColors.primaryColor(context).withOpacity(0.8)],

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

              ),

              boxShadow: [

                BoxShadow(

                  color: Color(0x331F6BFF),

                  blurRadius: 14,

                  offset: Offset(0, 8),

                ),

              ],

            ),

          ),

          Positioned(

            right: -12,

            bottom: -16,

            child: Icon(

              Icons.shopping_cart_outlined,

              size: 150,

              color: JuselColors.primaryForeground.withOpacity(0.08),

            ),

          ),

          Positioned.fill(

            child: Container(

              padding: const EdgeInsets.all(JuselSpacing.s16),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    'New Sale',

                    style: JuselTextStyles.headlineSmall(context).copyWith(

                      color: JuselColors.primaryForeground,

                      fontWeight: FontWeight.w800,

                      fontSize: 20,

                    ),

                  ),

                  const SizedBox(height: JuselSpacing.s8),

                  Text(

                    'Process a new customer order',

                    style: JuselTextStyles.bodySmall(context).copyWith(

                      color: JuselColors.primaryForeground.withOpacity(0.9),

                      fontWeight: FontWeight.w600,

                      fontSize: 16,

                    ),

                  ),

                  const SizedBox(height: JuselSpacing.s12),

                  Material(

                    color: Colors.transparent,

                    child: InkWell(

                      borderRadius: BorderRadius.circular(999),

                      onTap: () {
                        onNavigateToTab(2); // Navigate to Sales tab
                      },

                      child: Container(

                        decoration: BoxDecoration(

                          color: JuselColors.primaryForeground.withOpacity(0.22),

                          borderRadius: BorderRadius.circular(999),

                          border: Border.all(

                            color: JuselColors.primaryForeground.withOpacity(0.35),

                            width: 1,

                          ),

                          boxShadow: const [

                            BoxShadow(

                              color: Color(0x1AFFFFFF),

                              blurRadius: 8,

                              offset: Offset(0, 4),

                            ),

                          ],

                        ),

                        padding: const EdgeInsets.symmetric(

                          horizontal: 18,

                          vertical: 10,

                        ),

                        child: const Row(

                          mainAxisSize: MainAxisSize.min,

                          children: [

                            Text(

                              'Start Sale',

                              style: TextStyle(

                                fontWeight: FontWeight.w700,

                                fontSize: 14,

                                color: JuselColors.primaryForeground,

                              ),

                            ),

                            SizedBox(width: 8),

                            Icon(

                              Icons.arrow_forward,

                              size: 18,

                              color: JuselColors.primaryForeground,

                            ),

                          ],

                        ),

                      ),

                    ),

                  ),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}



class _SavedSaleCard extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const _SavedSaleCard(this.onNavigateToTab);

  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(JuselSpacing.s12),

      decoration: BoxDecoration(

        color: JuselColors.card(context),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: JuselColors.border(context)),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.02),

            blurRadius: 10,

            offset: const Offset(0, 4),

          ),

        ],

      ),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          Container(

            width: 38,

            height: 38,

            decoration: BoxDecoration(

              color: JuselColors.muted(context),

              borderRadius: BorderRadius.circular(10),

            ),

            child: Icon(

              Icons.receipt_long_outlined,

              color: JuselColors.primaryColor(context),

            ),

          ),

          const SizedBox(width: JuselSpacing.s12),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(

                  children: [

                    Expanded(

                      child: Text(

                        'Saved Sale',

                        style: JuselTextStyles.bodyMedium(context).copyWith(

                          fontWeight: FontWeight.w700,

                          color: JuselColors.foreground(context),

                          fontSize: 18,

                        ),

                      ),

                    ),

                    TextButton(

                      onPressed: () {
                        onNavigateToTab(2); // Navigate to Sales tab
                      },

                      style: TextButton.styleFrom(

                        minimumSize: Size.zero,

                        padding: EdgeInsets.zero,

                      ),

                      child: Row(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Text(

                            'Resume',

                            style: TextStyle(

                              color: JuselColors.primaryColor(context),

                              fontWeight: FontWeight.w800,

                              fontSize: 18,

                            ),

                          ),

                          SizedBox(width: 4),

                          Icon(

                            Icons.chevron_right,

                            size: 18,

                            color: JuselColors.primaryColor(context),

                          ),

                        ],

                      ),

                    ),

                  ],

                ),



                Text(

                  '3 items - 15 mins ago',

                  style: JuselTextStyles.bodySmall(context).copyWith(

                    color: JuselColors.mutedForeground(context),

                    fontWeight: FontWeight.w600,

                    fontSize: 14,

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




class _MetricCard extends StatelessWidget {

  final String label;

  final String value;



  const _MetricCard({required this.label, required this.value});



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(JuselSpacing.s12),

      decoration: BoxDecoration(

        color: JuselColors.card(context),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: JuselColors.border(context)),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.02),

            blurRadius: 10,

            offset: const Offset(0, 4),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: JuselTextStyles.bodySmall(context).copyWith(

              color: JuselColors.mutedForeground(context),

              fontWeight: FontWeight.w700,

              fontSize: 16,

            ),

          ),

          const SizedBox(height: JuselSpacing.s16),

          Text(

            value,

            style: JuselTextStyles.headlineLarge(context).copyWith(

              fontWeight: FontWeight.w900,

              color: JuselColors.foreground(context),

              fontSize: 24,

            ),

          ),

          const SizedBox(height: JuselSpacing.s16),

        ],

      ),

    );

  }

}




class _StockCard extends StatelessWidget {

  final _StockItem item;



  const _StockCard({required this.item});



  Color _statusColor(BuildContext context) {

    switch (item.status) {

      case _StockStatus.good:

        return JuselColors.successColor(context);

      case _StockStatus.low:

        return JuselColors.warningColor(context);

      case _StockStatus.out:

        return JuselColors.destructiveColor(context);

    }

  }



  Color _statusBg(BuildContext context) {

    switch (item.status) {

      case _StockStatus.good:

        return JuselColors.successColor(context).withOpacity(0.12);

      case _StockStatus.low:

        return JuselColors.warningColor(context).withOpacity(0.12);

      case _StockStatus.out:

        return JuselColors.destructiveColor(context).withOpacity(0.12);

    }

  }



  String _statusText() {

    switch (item.status) {

      case _StockStatus.good:

        return 'Good';

      case _StockStatus.low:

        return 'Low';

      case _StockStatus.out:

        return 'Out';

    }

  }



  @override

  Widget build(BuildContext context) {

    final statusColor = _statusColor(context);

    return Container(

      height: JuselSpacing.s32 * 2.5,

      padding: const EdgeInsets.all(JuselSpacing.s12),

      decoration: BoxDecoration(

        color: JuselColors.card(context),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: JuselColors.border(context)),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.02),

            blurRadius: 10,

            offset: const Offset(0, 4),

          ),

        ],

      ),

      child: Row(

        children: [

          Expanded(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  item.name,

                  style: JuselTextStyles.bodyMedium(context).copyWith(

                    fontWeight: FontWeight.w600,

                    color: JuselColors.foreground(context),

                    fontSize: 16,

                  ),

                ),

                const SizedBox(height: JuselSpacing.s4),

                Text(

                  item.category,

                  style: JuselTextStyles.bodySmall(context).copyWith(

                    color: JuselColors.mutedForeground(context),

                    fontWeight: FontWeight.w600,

                    fontSize: 14,

                  ),

                ),

              ],

            ),

          ),

          Container(

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(

              color: _statusBg(context),

              borderRadius: BorderRadius.circular(12),

            ),

            child: Text(

              _statusText(),

              style: TextStyle(

                color: statusColor,

                fontWeight: FontWeight.w800,

                fontSize: 12,

              ),

            ),

          ),

        ],

      ),

    );

  }

}



enum _StockStatus { good, low, out }



class _StockItem {

  final String name;

  final String category;

  final _StockStatus status;



  const _StockItem({

    required this.name,

    required this.category,

    required this.status,

  });

}



class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override

  Widget build(BuildContext context) {

    return BottomNavigationBar(

      currentIndex: currentIndex,

      onTap: onTap,

      items: const [

        BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Dashboard'),

        BottomNavigationBarItem(

          icon: Icon(Icons.inventory_2_outlined),

          label: 'Products',

        ),

        BottomNavigationBarItem(

          icon: Icon(Icons.point_of_sale_outlined),

          label: 'Sales',

        ),

      ],

    );

  }

}
