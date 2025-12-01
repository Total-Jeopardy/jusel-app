import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProductFilter _filter = ProductFilter.all;

  final List<_Product> _products = const [
    _Product(
      name: 'Orange Juice 1L',
      category: 'Local Drink',
      price: 3.50,
      cost: 1.10,
      status: ProductStatus.good,
      statusCount: 12,
    ),
    _Product(
      name: 'Cola 500ml',
      category: 'Drinks',
      price: 1.50,
      cost: 0.80,
      status: ProductStatus.low,
      statusCount: 4,
    ),
    _Product(
      name: 'Potato Chips Classic',
      category: 'Snacks',
      price: 2.00,
      cost: 1.20,
      status: ProductStatus.out,
      statusCount: 0,
    ),
    _Product(
      name: 'Mineral Water 1L',
      category: 'Drinks',
      price: 1.00,
      cost: 0.40,
      status: ProductStatus.good,
      statusCount: 45,
    ),
    _Product(
      name: 'Chocolate Bar',
      category: 'Snacks',
      price: 1.20,
      cost: 0.75,
      status: ProductStatus.good,
      statusCount: 28,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters(_products);

    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: JuselSpacing.s12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE5ECF9),
              child: Text(
                'JD',
                style: JuselTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: JuselColors.foreground,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add product
        },
        backgroundColor: JuselColors.primary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: JuselSpacing.s16),
              _SearchBar(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: JuselSpacing.s12),
              _FilterChips(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: JuselSpacing.s12),
              ...filtered.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: JuselSpacing.s12),
                  child: _ProductTile(product: p),
                ),
              ),
              const SizedBox(height: JuselSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }

  List<_Product> _applyFilters(List<_Product> list) {
    final query = _searchController.text.toLowerCase().trim();
    return list.where((p) {
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        ProductFilter.all => true,
        ProductFilter.drinks => p.category.toLowerCase().contains('drink'),
        ProductFilter.localDrinks =>
            p.category.toLowerCase() == 'local drink',
        ProductFilter.snacks => p.category.toLowerCase() == 'snacks',
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search),
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final ProductFilter selected;
  final ValueChanged<ProductFilter> onSelected;

  const _FilterChips({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            active: selected == ProductFilter.all,
            onTap: () => onSelected(ProductFilter.all),
          ),
          _Chip(
            label: 'Drinks',
            active: selected == ProductFilter.drinks,
            onTap: () => onSelected(ProductFilter.drinks),
          ),
          _Chip(
            label: 'Local Drinks',
            active: selected == ProductFilter.localDrinks,
            onTap: () => onSelected(ProductFilter.localDrinks),
          ),
          _Chip(
            label: 'Snacks',
            active: selected == ProductFilter.snacks,
            onTap: () => onSelected(ProductFilter.snacks),
          ),
        ].map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)).toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? JuselColors.foreground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? Colors.transparent : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: JuselTextStyles.bodySmall.copyWith(
            color: active ? Colors.white : JuselColors.mutedForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final _Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle(product.status, product.statusCount);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(JuselSpacing.s12),
        leading: _ProductThumb(name: product.name),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                product.name,
                overflow: TextOverflow.ellipsis,
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: JuselColors.foreground,
                ),
              ),
            ),
            const SizedBox(width: JuselSpacing.s8),
            Text(
              'GHS ${product.price.toStringAsFixed(2)}',
              style: JuselTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: JuselColors.foreground,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: JuselSpacing.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    product.category,
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: JuselColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: JuselSpacing.s8),
                  _StatusPill(
                    label: status.label,
                    color: status.color,
                    background: status.background,
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s6),
              Text(
                'Cost: GHS ${product.cost.toStringAsFixed(2)}',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: JuselColors.mutedForeground,
        ),
        onTap: () {
          // TODO: open product detail
        },
      ),
    );
  }

  _StatusStyle _statusStyle(ProductStatus status, int count) {
    switch (status) {
      case ProductStatus.good:
        return _StatusStyle(
          label: 'Good ($count)',
          color: const Color(0xFF16A34A),
          background: const Color(0xFFE9F8EF),
        );
      case ProductStatus.low:
        return _StatusStyle(
          label: 'Low ($count)',
          color: const Color(0xFFF59E0B),
          background: const Color(0xFFFFF7E6),
        );
      case ProductStatus.out:
        return const _StatusStyle(
          label: 'Out of Stock',
          color: JuselColors.destructive,
          background: Color(0xFFFFF1F2),
        );
    }
  }
}

class _ProductThumb extends StatelessWidget {
  final String name;

  const _ProductThumb({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.characters.take(2).toString(),
          style: JuselTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: JuselColors.foreground,
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
        style: JuselTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;

  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.white,
      selectedIndex: currentIndex,
      onDestinationSelected: (_) {},
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Products',
        ),
        NavigationDestination(
          icon: Icon(Icons.point_of_sale_outlined),
          label: 'Sales',
        ),
        NavigationDestination(
          icon: Icon(Icons.store_mall_directory_outlined),
          label: 'Stock',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Reports',
        ),
      ],
    );
  }
}

class _Product {
  final String name;
  final String category;
  final double price;
  final double cost;
  final ProductStatus status;
  final int statusCount;

  const _Product({
    required this.name,
    required this.category,
    required this.price,
    required this.cost,
    required this.status,
    required this.statusCount,
  });
}

enum ProductStatus { good, low, out }

enum ProductFilter { all, drinks, localDrinks, snacks }

class _StatusStyle {
  final String label;
  final Color color;
  final Color background;

  const _StatusStyle({
    required this.label,
    required this.color,
    required this.background,
  });
}
