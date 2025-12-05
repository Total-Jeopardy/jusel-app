import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/sales/models/cart_item.dart';
import 'package:jusel_app/features/sales/providers/cart_provider.dart';
import 'package:jusel_app/features/sales/view/cart_view.dart';
import 'package:jusel_app/features/sales/view/product_selection_modal.dart';
import 'package:jusel_app/features/products/view/product_detail_screen.dart';

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

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0; // 0 = Add Item, 1 = Cart
  String _searchQuery = '';

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
  ) async {
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
          backgroundColor: JuselColors.destructive,
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
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $quantity ${product.name} to cart'),
          backgroundColor: JuselColors.success,
        ),
      );
      // Switch to cart view
      setState(() {
        _currentIndex = 1;
      });
    }
  }

  void _openProductModal(ProductsTableData product) {
    ProductSelectionModal.show(
      context,
      product: product,
      onAddToSale: (id, qty, price) => _handleAddToSale(product, qty, price),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final cartNotifier = ref.read(cartProvider.notifier);
            cartNotifier.clearCart();
            Navigator.of(context).maybePop();
          },
        ),
        title: const Text(
          'New Sale',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              final cartNotifier = ref.read(cartProvider.notifier);
              cartNotifier.clearCart();
              Navigator.of(context).maybePop();
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
                        style: const TextStyle(
                          color: Colors.white,
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
    );
  }

  Widget _buildAddItemView() {
    final productsAsync = ref.watch(_activeProductsWithStockProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: JuselSpacing.s16),
          Text(
            'Add Item',
            style: JuselTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: JuselColors.mutedForeground,
            ),
          ),
          const SizedBox(height: JuselSpacing.s8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search or Scan Product...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: JuselSpacing.s24),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load products: $e',
                  style: JuselTextStyles.bodyMedium.copyWith(
                    color: JuselColors.destructive,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              data: (items) {
                final filtered = items.where((item) {
                  if (_searchQuery.isEmpty) return true;
                  final name = item.product.name.toLowerCase();
                  final category = item.product.category.toLowerCase();
                  return name.contains(_searchQuery) ||
                      category.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: JuselColors.mutedForeground,
                        ),
                        const SizedBox(height: JuselSpacing.s16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No products available'
                              : 'No products found',
                          style: JuselTextStyles.bodyMedium.copyWith(
                            color: JuselColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
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
                                const SnackBar(
                                  content: Text('This product is out of stock'),
                                  backgroundColor: JuselColors.destructive,
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
    return Card(
      margin: const EdgeInsets.only(bottom: JuselSpacing.s12),
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
                      style: JuselTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s4),
                    Text(
                      product.category,
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
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
                    style: JuselTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: JuselColors.primary,
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
                          ? JuselColors.muted
                          : JuselColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      disabled
                          ? 'Out of stock'
                          : '$stock in stock',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color:
                            disabled ? JuselColors.mutedForeground : JuselColors.success,
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
