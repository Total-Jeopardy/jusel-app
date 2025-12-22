import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/ui/components/profile_avatar.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/utils/product_constants.dart';
import 'package:jusel_app/features/account/view/account_screen.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_tab_provider.dart';
import 'package:jusel_app/features/products/view/add_product_screen.dart';
import 'package:jusel_app/features/products/providers/products_provider.dart';
import 'package:jusel_app/features/stock/view/stock_detail_screen.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key, this.showAddButton = true});

  final bool showAddButton;

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProductFilter _filter = ProductFilter.all;

  List<_Product> _products = const [];
  bool _loading = true;
  String? _error;
  int? _lastRefreshTrigger;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final db = ref.read(appDatabaseProvider);
      final inventory = ref.read(inventoryServiceProvider);
      final products = await db.productsDao.getAllProducts();
      final stockMap = await inventory.getAllCurrentStock();
      final mapped = products.map((p) {
        final stock = stockMap[p.id] ?? p.currentStockQty;
        final status = _statusFromStock(stock);
        return _Product(
          id: p.id,
          name: p.name,
          category: p.category,
          subcategory: p.subcategory,
          isProduced: p.isProduced,
          price: p.currentSellingPrice,
          cost: p.currentCostPrice ?? 0,
          imageUrl: p.imageUrl,
          status: status,
          statusCount: stock,
        );
      }).toList();
      setState(() {
        _products = mapped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load products: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isApprentice = authState.valueOrNull?.role == 'apprentice';
    // Watch for refresh trigger
    final refreshTrigger = ref.watch(productsRefreshTriggerProvider);
    if (_lastRefreshTrigger != null &&
        refreshTrigger != _lastRefreshTrigger &&
        refreshTrigger > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProducts(); // Reload products when trigger changes
      });
    }
    _lastRefreshTrigger = refreshTrigger;

    final filtered = _applyFilters(_products);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            ref.read(dashboardTabProvider.notifier).goToDashboard();
          }
        }
      },
      child: Scaffold(
        backgroundColor: JuselColors.background(context),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(dashboardTabProvider.notifier).goToDashboard();
            },
          ),
          title: const Text(
            'Products',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: JuselSpacing.s12),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  );
                },
                child: Consumer(
                  builder: (context, ref, _) {
                    final user = ref.watch(authViewModelProvider).valueOrNull;
                    return ProfileAvatar(
                      radius: 20,
                      userId: user?.uid,
                      userName: user?.name,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: (!widget.showAddButton || isApprentice)
            ? null
            : FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  );
                  // Refresh products list if a product was successfully added
                  if (result == true) {
                    _loadProducts();
                  }
                },
                backgroundColor: JuselColors.primaryColor(context),
                child: const Icon(Icons.add),
              ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: JuselColors.border(context)),
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
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(JuselSpacing.s12),
                    child: Text(
                      _error!,
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.destructiveColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(JuselSpacing.s12),
                    child: Text(
                      'No products found.',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
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
      ),
    );
  }

  ProductStatus _statusFromStock(int stock) {
    if (stock <= 0) return ProductStatus.out;
    if (stock <= 10) return ProductStatus.low;
    return ProductStatus.good;
  }

  List<_Product> _applyFilters(List<_Product> list) {
    final query = _searchController.text.toLowerCase().trim();
    return list.where((p) {
      final matchesQuery =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        ProductFilter.all => true,
        ProductFilter.drinks => p.category == ProductCategories.drink,
        ProductFilter.localDrinks =>
          p.category == ProductCategories.drink &&
              p.subcategory == ProductSubcategories.locallyMade,
        ProductFilter.snacks => p.category == ProductCategories.snack,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search),
        fillColor: JuselColors.muted(context),
        filled: true,
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
    );
  }
}

class _FilterChips extends StatelessWidget {
  final ProductFilter selected;
  final ValueChanged<ProductFilter> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final drinkLabel = ProductHelpers.categoryToDisplay(
      ProductCategories.drink,
    );
    final snackLabel = ProductHelpers.categoryToDisplay(
      ProductCategories.snack,
    );
    final locallyMadeLabel = ProductHelpers.subcategoryToDisplay(
      ProductSubcategories.locallyMade,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            [
                  _Chip(
                    label: 'All',
                    active: selected == ProductFilter.all,
                    onTap: () => onSelected(ProductFilter.all),
                  ),
                  _Chip(
                    label: drinkLabel,
                    active: selected == ProductFilter.drinks,
                    onTap: () => onSelected(ProductFilter.drinks),
                  ),
                  _Chip(
                    label: locallyMadeLabel,
                    active: selected == ProductFilter.localDrinks,
                    onTap: () => onSelected(ProductFilter.localDrinks),
                  ),
                  _Chip(
                    label: snackLabel,
                    active: selected == ProductFilter.snacks,
                    onTap: () => onSelected(ProductFilter.snacks),
                  ),
                ]
                .map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: w,
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? JuselColors.foreground(context)
              : JuselColors.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? Colors.transparent : JuselColors.border(context),
          ),
        ),
        child: Text(
          label,
          style: JuselTextStyles.bodySmall(context).copyWith(
            color: active
                ? JuselColors.background(context)
                : JuselColors.mutedForeground(context),
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
    final status = _statusStyle(context, product.status, product.statusCount);
    final categoryLabel = ProductHelpers.categoryToDisplay(product.category);
    final subcategoryLabel = product.subcategory != null
        ? ProductHelpers.subcategoryToDisplay(product.subcategory!)
        : null;
    final categoryDisplay = subcategoryLabel != null
        ? '$categoryLabel · $subcategoryLabel'
        : categoryLabel;
    return Material(
      color: JuselColors.card(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StockDetailScreen(productId: product.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JuselColors.border(context)),
          ),
          padding: const EdgeInsets.all(JuselSpacing.s12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductThumb(name: product.name, imageUrl: product.imageUrl),
              const SizedBox(width: JuselSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            overflow: TextOverflow.ellipsis,
                            style: JuselTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: JuselColors.foreground(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: JuselSpacing.s8),
                        Text(
                          'GHS ${product.price.toStringAsFixed(2)}',
                          style: JuselTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w800,
                            color: JuselColors.foreground(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s8),
                    Row(
                      children: [
                        Text(
                          categoryDisplay,
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
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
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: JuselColors.mutedForeground(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusStyle _statusStyle(
    BuildContext context,
    ProductStatus status,
    int count,
  ) {
    switch (status) {
      case ProductStatus.good:
        return _StatusStyle(
          label: 'Good ($count)',
          color: JuselColors.successColor(context),
          background: JuselColors.successColor(context).withOpacity(0.12),
        );
      case ProductStatus.low:
        return _StatusStyle(
          label: 'Low ($count)',
          color: JuselColors.warningColor(context),
          background: JuselColors.warningColor(context).withOpacity(0.12),
        );
      case ProductStatus.out:
        return _StatusStyle(
          label: 'Out of Stock',
          color: JuselColors.destructiveColor(context),
          background: JuselColors.destructiveColor(context).withOpacity(0.12),
        );
    }
  }
}

class _ProductThumb extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _ProductThumb({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final thumb = Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: JuselColors.muted(context),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (_, __, ___) => _Initials(name: name),
            )
          : _Initials(name: name),
    );

    return thumb;
  }
}

class _Initials extends StatelessWidget {
  final String name;

  const _Initials({required this.name});

  @override
  Widget build(BuildContext context) {
    // Extract first 2 characters, handling edge cases
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().length >= 2
        ? name.trim().substring(0, 2).toUpperCase()
        : name.trim().substring(0, 1).toUpperCase();

    return Center(
      child: Text(
        initials,
        style: JuselTextStyles.bodyMedium(context).copyWith(
          fontWeight: FontWeight.w800,
          color: JuselColors.foreground(context),
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
        style: JuselTextStyles.bodySmall(
          context,
        ).copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Product {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final bool isProduced;
  final double price;
  final double cost;
  final String? imageUrl;
  final ProductStatus status;
  final int statusCount;

  const _Product({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.isProduced,
    required this.price,
    required this.cost,
    required this.imageUrl,
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
