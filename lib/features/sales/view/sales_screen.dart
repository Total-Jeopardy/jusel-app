import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/sales/models/cart_item.dart';
import 'package:jusel_app/features/sales/providers/cart_provider.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_tab_provider.dart';
import 'package:jusel_app/features/products/view/product_detail_screen.dart';
import 'package:jusel_app/features/sales/view/cart_view.dart';
import 'package:jusel_app/features/sales/view/product_selection_modal.dart';
import 'package:jusel_app/features/sales/providers/sales_history_provider.dart';

final _activeProductsWithStockProvider = FutureProvider.autoDispose<
    List<_ProductWithStock>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final inventory = ref.read(inventoryServiceProvider);

  final products = await db.productsDao.getAllProducts();
  final active = products.where((p) => p.status == 'active').toList();

  final withStock = await Future.wait(
    active.map((p) async {
      final stock = await inventory.getCurrentStock(p.id);
      return _ProductWithStock(product: p, stock: stock);
    }),
  );

  return withStock;
});

enum SalesProductFilter {
  all,
  recentlySold,
  mostSold,
  recentlyAccessed,
}

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0; // 0 = Add Item, 1 = Cart
  String _searchQuery = '';
  SalesProductFilter _selectedFilter = SalesProductFilter.all;

  final Map<String, DateTime> _recentlyAccessed = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _markAccessed(String productId) {
    setState(() {
      _recentlyAccessed[productId] = DateTime.now();
    });
  }

  List<_ProductWithStock> _applyFilters(
    List<_ProductWithStock> items,
    List<SalesHistoryEntry> history,
  ) {
    switch (_selectedFilter) {
      case SalesProductFilter.all:
        return items;
      case SalesProductFilter.recentlySold:
        final cutoff = DateTime.now().subtract(const Duration(days: 7));
        final byId = {for (final h in history) h.productId: h};
        final filtered = items.where((item) {
          final hist = byId[item.product.id];
          return hist?.lastSoldAt != null && hist!.lastSoldAt!.isAfter(cutoff);
        }).toList();
        filtered.sort((a, b) {
          final lastA = byId[a.product.id]?.lastSoldAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final lastB = byId[b.product.id]?.lastSoldAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return lastB.compareTo(lastA);
        });
        return filtered;
      case SalesProductFilter.mostSold:
        final byId = {for (final h in history) h.productId: h};
        final filtered = items.where((item) {
          final hist = byId[item.product.id];
          return hist != null && hist.totalSold > 0;
        }).toList();
        filtered.sort((a, b) {
          final totalA = byId[a.product.id]?.totalSold ?? 0;
          final totalB = byId[b.product.id]?.totalSold ?? 0;
          return totalB.compareTo(totalA);
        });
        return filtered;
      case SalesProductFilter.recentlyAccessed:
        if (_recentlyAccessed.isEmpty) return items;
        final itemsById = {for (final item in items) item.product.id: item};
        final sortedIds = _recentlyAccessed.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final ordered = <_ProductWithStock>[];
        for (final entry in sortedIds) {
          final item = itemsById[entry.key];
          if (item != null) ordered.add(item);
        }
        return ordered.isEmpty ? items : ordered;
    }
  }

  Future<bool> _showCancelSaleDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: JuselColors.card(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Cancel Sale?'),
              ],
            ),
            content: const Text(
              'Are you sure you want to cancel this sale? All items in cart will be removed.',
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep Sale'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: JuselColors.destructiveColor(context),
                  foregroundColor: JuselColors.destructiveForeground,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Cancel Sale'),
              ),
            ],
          ),
        ) ??
        false;
  }

  int _cartQtyForProduct(String productId) {
    final cart = ref.read(cartProvider);
    return cart.items
        .where((item) => item.productId == productId)
        .fold<int>(0, (sum, item) => sum + item.quantity);
  }

  Future<void> _handleAddToSale(
    ProductsTableData product,
    int quantity,
    double? overriddenPrice,
    String? overrideReason,
  ) async {
    _markAccessed(product.id);
    final inventory = ref.read(inventoryServiceProvider);
    final availableStock = await inventory.getCurrentStock(product.id);
    final inCart = _cartQtyForProduct(product.id);
    if (quantity + inCart > availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            availableStock <= 0
                ? 'This product is out of stock.'
                : 'Only $availableStock in stock. Remove items from cart or reduce quantity.',
          ),
          backgroundColor: JuselColors.destructiveColor(context),
        ),
      );
      return;
    }

    final cartNotifier = ref.read(cartProvider.notifier);

    cartNotifier.addItem(
      CartItem(
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        unitPrice: overriddenPrice ?? product.currentSellingPrice,
        overriddenPrice: overriddenPrice,
        overrideReason: overrideReason,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $quantity ${product.name} to cart'),
          backgroundColor: JuselColors.successColor(context),
        ),
      );
      // Switch to cart view
      setState(() {
        _currentIndex = 1;
      });
    }
  }

  void _openProductModal(ProductsTableData product) {
    _markAccessed(product.id);
    ProductSelectionModal.show(
      context,
      product: product,
      onAddToSale: (id, qty, price, reason) =>
          _handleAddToSale(product, qty, price, reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // If there are routes to pop (detail screens), pop them
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            // Otherwise, go back to dashboard tab
            ref.read(dashboardTabProvider.notifier).goToDashboard();
          }
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final cartNotifier = ref.read(cartProvider.notifier);
            final confirm = await _showCancelSaleDialog();
            if (!confirm) return;
            cartNotifier.clearCart();
            ref.read(dashboardTabProvider.notifier).goToDashboard();
          },
        ),
        title: const Text(
          'New Sale',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () async {
              final confirm = await _showCancelSaleDialog();
              if (!confirm) return;
              final cartNotifier = ref.read(cartProvider.notifier);
              cartNotifier.clearCart();
              ref.read(dashboardTabProvider.notifier).goToDashboard();
            },
            child: const Text(
              'Cancel Sale',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildAddItemView() : const CartView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Add Item',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: TextStyle(
                          color: JuselColors.primaryForeground,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildAddItemView() {
    final historyAsync = ref.watch(salesHistoryProvider);
    final productsAsync = ref.watch(_activeProductsWithStockProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: JuselColors.border(context)),
          const SizedBox(height: JuselSpacing.s16),
          Text(
            'Add Item',
            style: JuselTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
              color: JuselColors.mutedForeground(context),
            ),
          ),
          const SizedBox(height: JuselSpacing.s8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search or Scan Product...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: JuselColors.muted(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JuselColors.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JuselColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: JuselColors.primaryColor(context),
                  width: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: JuselSpacing.s24),
          historyAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(bottom: JuselSpacing.s12),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (_) => const SizedBox.shrink(),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: JuselSpacing.s12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedFilter == SalesProductFilter.all,
                  onTap: () => setState(() {
                    _selectedFilter = SalesProductFilter.all;
                  }),
                ),
                _FilterChip(
                  label: 'Recently Sold',
                  selected: _selectedFilter == SalesProductFilter.recentlySold,
                  onTap: () => setState(() {
                    _selectedFilter = SalesProductFilter.recentlySold;
                  }),
                ),
                _FilterChip(
                  label: 'Most Sold',
                  selected: _selectedFilter == SalesProductFilter.mostSold,
                  onTap: () => setState(() {
                    _selectedFilter = SalesProductFilter.mostSold;
                  }),
                ),
                _FilterChip(
                  label: 'Recently Accessed',
                  selected:
                      _selectedFilter == SalesProductFilter.recentlyAccessed,
                  onTap: () => setState(() {
                    _selectedFilter = SalesProductFilter.recentlyAccessed;
                  }),
                ),
              ]
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(right: JuselSpacing.s8),
                      child: w,
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load products: $e',
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    color: JuselColors.destructiveColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              data: (items) {
                final history = historyAsync.asData?.value ?? const <SalesHistoryEntry>[];
                final filtered = items.where((item) {
                  if (_searchQuery.isEmpty) return true;
                  final name = item.product.name.toLowerCase();
                  final category = item.product.category.toLowerCase();
                  return name.contains(_searchQuery) ||
                      category.contains(_searchQuery);
                }).toList();

                final displayItems = _applyFilters(filtered, history);

                if (displayItems.isEmpty) {
                  final emptyText = switch (_selectedFilter) {
                    SalesProductFilter.all =>
                        _searchController.text.isEmpty
                            ? 'No products available'
                            : 'No products found',
                    SalesProductFilter.recentlySold =>
                        'No products sold in the last 7 days.',
                    SalesProductFilter.mostSold =>
                        'No sales history to rank products.',
                    SalesProductFilter.recentlyAccessed =>
                        'No recently accessed products.',
                  };
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: JuselColors.mutedForeground(context),
                        ),
                        const SizedBox(height: JuselSpacing.s16),
                        Text(
                          emptyText,
                          style: JuselTextStyles.bodyMedium(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) {
                    final item = displayItems[index];
                    final isOutOfStock = item.stock <= 0;
                    final product =
                        item.product.copyWith(currentStockQty: item.stock);
                    return _ProductCard(
                      product: product,
                      stock: item.stock,
                      disabled: isOutOfStock,
                      onTap: isOutOfStock
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('This product is out of stock'),
                                  backgroundColor: JuselColors.destructiveColor(context),
                                ),
                              );
                            }
                          : () {
                              _openProductModal(product);
                            },
                      onViewDetail: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(productId: product.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductsTableData product;
  final int stock;
  final bool disabled;
  final VoidCallback onTap;
  final VoidCallback onViewDetail;

  const _ProductCard({
    required this.product,
    required this.stock,
    required this.disabled,
    required this.onTap,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: JuselSpacing.s12),
        color: disabled ? JuselColors.muted(context).withOpacity(0.3) : null,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(JuselSpacing.s16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: JuselTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: disabled ? JuselColors.mutedForeground(context) : null,
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s4),
                      Text(
                        product.category,
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                        ),
                      ),
                      TextButton(
                        onPressed: onViewDetail,
                        child: const Text(
                          'View details',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'GHS ${product.currentSellingPrice.toStringAsFixed(2)}',
                      style: JuselTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: disabled ? JuselColors.mutedForeground(context) : JuselColors.primaryColor(context),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: disabled
                            ? JuselColors.muted(context)
                            : JuselColors.successColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        disabled
                            ? 'Out of stock'
                            : '$stock in stock',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color:
                              disabled ? JuselColors.mutedForeground(context) : JuselColors.successColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductWithStock {
  final ProductsTableData product;
  final int stock;

  const _ProductWithStock({
    required this.product,
    required this.stock,
  });
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? JuselColors.foreground(context) : JuselColors.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : JuselColors.border(context),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: JuselTextStyles.bodySmall(context).copyWith(
            color: selected ? JuselColors.background(context) : JuselColors.mutedForeground(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
