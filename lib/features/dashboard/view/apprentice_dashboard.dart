import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/account/view/account_screen.dart';



class ApprenticeDashboard extends StatelessWidget {

  const ApprenticeDashboard({super.key});



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: JuselColors.background,

      bottomNavigationBar: _BottomNav(),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(

                children: [

                  Container(

                    width: 40,

                    height: 40,

                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(12),

                      gradient: const LinearGradient(

                        colors: [Color(0xFF1F6BFF), Color(0xFF6A63FF)],

                        begin: Alignment.topLeft,

                        end: Alignment.bottomRight,

                      ),

                    ),

                    child: const Icon(

                      Icons.store_mall_directory_rounded,

                      color: Colors.white,

                    ),

                  ),

                  const SizedBox(width: JuselSpacing.s12),

                  Text(

                    'Jusel',

                    style: JuselTextStyles.bodyMedium.copyWith(

                      fontWeight: FontWeight.w900,

                      color: JuselColors.foreground,

                      fontSize: 20,

                    ),

                  ),

                  const Spacer(),

                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountScreen(),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(
                        'assets/avatar_placeholder.png',
                      ),
                    ),
                  ),

                ],

              ),

              const SizedBox(height: JuselSpacing.s12),

              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              const SizedBox(height: JuselSpacing.s16),

              Text(

                'Welcome, Apprentice',

                style: JuselTextStyles.headlineLarge.copyWith(

                  fontWeight: FontWeight.w700,

                ),

              ),

              const SizedBox(height: JuselSpacing.s6),

              Text(

                'Ready to make some sales?',

                style: JuselTextStyles.bodySmall.copyWith(

                  color: JuselColors.mutedForeground,

                  fontWeight: FontWeight.w600,

                  fontSize: 14,

                ),

              ),

              const SizedBox(height: JuselSpacing.s20),

              _AlertCard(),

              const SizedBox(height: JuselSpacing.s20),

              _NewSaleCard(),

              const SizedBox(height: JuselSpacing.s12),

              _SavedSaleCard(),

              const SizedBox(height: JuselSpacing.s12),

              _MetricsRow(),

              const SizedBox(height: JuselSpacing.s16),

              _StockOverview(),

              const SizedBox(height: JuselSpacing.s16),

            ],

          ),

        ),

      ),

    );

  }

}



class _AlertCard extends StatelessWidget {

  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.symmetric(

        horizontal: JuselSpacing.s16,

        vertical: JuselSpacing.s16,

      ),

      decoration: BoxDecoration(

        color: const Color(0xFFFFF6E9),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: const Color(0xFFF2D8A2)),

      ),

      child: Row(

        children: [

          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),

          const SizedBox(width: JuselSpacing.s12),

          Expanded(

            child: Text(

              'Alert: 2 items are running low on stock.',

              style: JuselTextStyles.bodySmall.copyWith(

                color: const Color(0xFF92400E),

                fontWeight: FontWeight.w600,

                fontSize: 13,

              ),

            ),

          ),

        ],

      ),

    );

  }

}



class _NewSaleCard extends StatelessWidget {

  @override

  Widget build(BuildContext context) {

    return ClipRRect(

      borderRadius: BorderRadius.circular(16),

      child: Stack(

        children: [

          Container(

            width: double.infinity,

            height: 170,

            decoration: const BoxDecoration(

              gradient: LinearGradient(

                colors: [Color(0xFF2478FF), Color(0xFF5594FF)],

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

              color: Colors.white.withOpacity(0.08),

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

                    style: JuselTextStyles.headlineSmall.copyWith(

                      color: Colors.white,

                      fontWeight: FontWeight.w800,

                      fontSize: 20,

                    ),

                  ),

                  const SizedBox(height: JuselSpacing.s8),

                  Text(

                    'Process a new customer order',

                    style: JuselTextStyles.bodySmall.copyWith(

                      color: Colors.white.withOpacity(0.9),

                      fontWeight: FontWeight.w600,

                      fontSize: 16,

                    ),

                  ),

                  const SizedBox(height: JuselSpacing.s12),

                  Material(

                    color: Colors.transparent,

                    child: InkWell(

                      borderRadius: BorderRadius.circular(999),

                      onTap: () {},

                      child: Container(

                        decoration: BoxDecoration(

                          color: Colors.white.withOpacity(0.22),

                          borderRadius: BorderRadius.circular(999),

                          border: Border.all(

                            color: Colors.white.withOpacity(0.35),

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

                                color: Colors.white,

                              ),

                            ),

                            SizedBox(width: 8),

                            Icon(

                              Icons.arrow_forward,

                              size: 18,

                              color: Colors.white,

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

  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(JuselSpacing.s12),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE5E7EB)),

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

              color: JuselColors.muted,

              borderRadius: BorderRadius.circular(10),

            ),

            child: const Icon(

              Icons.receipt_long_outlined,

              color: JuselColors.primary,

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

                        style: JuselTextStyles.bodyMedium.copyWith(

                          fontWeight: FontWeight.w700,

                          color: JuselColors.foreground,

                          fontSize: 18,

                        ),

                      ),

                    ),

                    TextButton(

                      onPressed: () {},

                      style: TextButton.styleFrom(

                        minimumSize: Size.zero,

                        padding: EdgeInsets.zero,

                      ),

                      child: const Row(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Text(

                            'Resume',

                            style: TextStyle(

                              color: JuselColors.primary,

                              fontWeight: FontWeight.w800,

                              fontSize: 18,

                            ),

                          ),

                          SizedBox(width: 4),

                          Icon(

                            Icons.chevron_right,

                            size: 18,

                            color: JuselColors.primary,

                          ),

                        ],

                      ),

                    ),

                  ],

                ),



                Text(

                  '3 items - 15 mins ago',

                  style: JuselTextStyles.bodySmall.copyWith(

                    color: JuselColors.mutedForeground,

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



class _MetricsRow extends StatelessWidget {

  @override

  Widget build(BuildContext context) {

    return const Row(

      children: [

        Expanded(

          child: _MetricCard(label: "Today's Sales", value: 'GHS 24,500'),

        ),

        SizedBox(width: JuselSpacing.s12),

        Expanded(

          child: _MetricCard(label: 'Items Sold', value: '18'),

        ),

      ],

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

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE5E7EB)),

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

            style: JuselTextStyles.bodySmall.copyWith(

              color: JuselColors.mutedForeground,

              fontWeight: FontWeight.w700,

              fontSize: 16,

            ),

          ),

          const SizedBox(height: JuselSpacing.s16),

          Text(

            value,

            style: JuselTextStyles.headlineLarge.copyWith(

              fontWeight: FontWeight.w900,

              color: JuselColors.foreground,

              fontSize: 24,

            ),

          ),

          const SizedBox(height: JuselSpacing.s16),

        ],

      ),

    );

  }

}



class _StockOverview extends StatelessWidget {

  final List<_StockItem> items = const [

    _StockItem(

      name: 'Orange Juice 1L',

      category: 'Drinks',

      status: _StockStatus.good,

    ),

    _StockItem(

      name: 'Whole Wheat Bread',

      category: 'Bakery',

      status: _StockStatus.low,

    ),

    _StockItem(

      name: 'Chocolate Bar',

      category: 'Snacks',

      status: _StockStatus.good,

    ),

    _StockItem(

      name: 'Dairy Milk 500ml',

      category: 'Dairy',

      status: _StockStatus.out,

    ),

    _StockItem(

      name: 'Bottled Water 50cl',

      category: 'Drinks',

      status: _StockStatus.good,

    ),

  ];



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Stock Overview',

          style: JuselTextStyles.headlineSmall.copyWith(

            fontWeight: FontWeight.w700,

          ),

        ),

        const SizedBox(height: JuselSpacing.s16),

        ...items.map(

          (item) => Padding(

            padding: const EdgeInsets.only(bottom: JuselSpacing.s12),

            child: _StockCard(item: item),

          ),

        ),

      ],

    );

  }

}



class _StockCard extends StatelessWidget {

  final _StockItem item;



  const _StockCard({required this.item});



  Color _statusColor() {

    switch (item.status) {

      case _StockStatus.good:

        return const Color(0xFF22C55E);

      case _StockStatus.low:

        return const Color(0xFFF59E0B);

      case _StockStatus.out:

        return const Color(0xFFEF4444);

    }

  }



  Color _statusBg() {

    switch (item.status) {

      case _StockStatus.good:

        return const Color(0xFFE9FAF0);

      case _StockStatus.low:

        return const Color(0xFFFFF3E0);

      case _StockStatus.out:

        return const Color(0xFFFDECEC);

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

    final statusColor = _statusColor();

    return Container(

      height: JuselSpacing.s32 * 2.5,

      padding: const EdgeInsets.all(JuselSpacing.s12),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: const Color(0xFFE5E7EB)),

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

                  style: JuselTextStyles.bodyMedium.copyWith(

                    fontWeight: FontWeight.w600,

                    color: JuselColors.foreground,

                    fontSize: 16,

                  ),

                ),

                const SizedBox(height: JuselSpacing.s4),

                Text(

                  item.category,

                  style: JuselTextStyles.bodySmall.copyWith(

                    color: JuselColors.mutedForeground,

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

              color: _statusBg(),

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

  @override

  Widget build(BuildContext context) {

    return BottomNavigationBar(

      currentIndex: 0,

      onTap: (_) {},

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

