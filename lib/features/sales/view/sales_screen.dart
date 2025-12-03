import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/sales/models/cart_item.dart';
import 'package:jusel_app/features/sales/providers/cart_provider.dart';
import 'package:jusel_app/features/sales/view/cart_view.dart';
import 'package:jusel_app/features/sales/view/product_selection_modal.dart';
import 'package:jusel_app/features/products/view/product_detail_screen.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductsTableData> _allProducts = [];
  List<ProductsTableData> _filteredProducts = [];
  bool _isLoading = true;
  int _currentIndex = 0; // 0 = Add Item, 1 = Cart

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final products = await db.productsDao.getAllProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = products.where((p) => p.status == 'active').toList();
        _filteredProducts = _allProducts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load products'),
          backgroundColor: JuselColors.destructive,
        ),
      );
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query) ||
                  product.category.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  void _handleAddToSale(
    String productId,
    int quantity,
    double? overriddenPrice,
  ) {
    ProductsTableData? product;
    for (final p in [..._allProducts, ..._filteredProducts]) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product not found or unavailable'),
          backgroundColor: JuselColors.destructive,
        ),
      );
      return;
    }

    final cartNotifier = ref.read(cartProvider.notifier);

    cartNotifier.addItem(
      CartItem(
        productId: productId,
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
      onAddToSale: _handleAddToSale,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
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
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: JuselSpacing.s12),
      child: InkWell(
        onTap: onTap,
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
                    Text(product.category, style: JuselTextStyles.bodySmall),
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
                      color: JuselColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${product.currentStockQty} in stock',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.success,
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
