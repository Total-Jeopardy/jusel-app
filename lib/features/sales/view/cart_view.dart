import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:jusel_app/features/sales/models/cart_item.dart';
import 'package:jusel_app/features/sales/providers/cart_provider.dart';
import 'package:jusel_app/features/sales/view/sales_completed_screen.dart';

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: JuselColors.mutedForeground(context),
            ),
            const SizedBox(height: JuselSpacing.s16),
            Text(
              'Your cart is empty',
              style: JuselTextStyles.bodyMedium(context).copyWith(
                color: JuselColors.mutedForeground(context),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Text(
                'Cart',
                style: JuselTextStyles.headlineLarge(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: JuselSpacing.s8),
              Text(
                '${cart.itemCount} items',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                ),
              ),
            ],
          ),
        ),

        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartItemCard(
                item: item,
                onDelete: () => cartNotifier.removeItem(index),
              );
            },
          ),
        ),

        // Total Amount and Finalize Button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: JuselColors.card(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: JuselTextStyles.bodyLarge(context)),
                  Text(
                    'GHS ${cart.totalAmount.toStringAsFixed(2)}',
                    style: JuselTextStyles.headlineMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s16),

              // Finalize Sale Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleFinalizeSale(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JuselColors.secondaryColor(context),
                    foregroundColor: JuselColors.secondaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Finalize Sale',
                        style: JuselTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: JuselColors.secondaryForeground,
                        ),
                      ),
                      const SizedBox(width: JuselSpacing.s8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleFinalizeSale(BuildContext context, WidgetRef ref) async {
    final cart = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final salesService = ref.read(salesServiceProvider);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to make a sale')),
        );
      }
      return;
    }

    if (cart.items.isEmpty) {
      return;
    }

    final proceed = await _showFinalizeSaleDialog(
      context,
      total: cart.totalAmount,
      itemCount: cart.itemCount,
    );
    if (!proceed) return;

    // Get payment method from user
    final paymentMethod = await _showPaymentMethodDialog(context);
    if (paymentMethod == null) return; // User cancelled

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // Process each item in the cart
      final itemsSnapshot = List<CartItem>.from(cart.items);
      final subtotal = cart.totalAmount;
      double totalProfit = 0;
      for (final item in cart.items) {
        final summary = await salesService.sellProduct(
          productId: item.productId,
          quantity: item.quantity,
          createdByUserId: user.uid,
          paymentMethod: paymentMethod,
          overriddenPrice: item.overriddenPrice,
          priceOverrideReason: item.overrideReason,
        );
        totalProfit += summary.profit;
      }

      // Clear cart after successful sale
      cartNotifier.clearCart();

      // Invalidate dashboard to refresh metrics/low stock
      ref.invalidate(dashboardProvider);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SalesCompletedScreen(
              items: itemsSnapshot,
              subtotal: subtotal,
              netProfit: totalProfit,
              sellerName: user.displayName ?? 'Sales User',
              paymentMethod: paymentMethod == 'cash' ? 'Cash' : 'Mobile Money',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    }
  }

  Future<bool> _showFinalizeSaleDialog(
    BuildContext context, {
    required double total,
    required int itemCount,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: JuselColors.card(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle_outline, color: JuselColors.successColor(context)),
                const SizedBox(width: 8),
                const Text('Finalize Sale?'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: GHS ${total.toStringAsFixed(2)}',
                  style: JuselTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Items: $itemCount',
                  style: JuselTextStyles.bodyMedium(context),
                ),
                const SizedBox(height: 12),
                Text(
                  'Proceed with this sale?',
                  style: JuselTextStyles.bodySmall(context).copyWith(color: JuselColors.mutedForeground(context)),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Review'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: JuselColors.primaryColor(context),
                  foregroundColor: JuselColors.primaryForeground,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _showPaymentMethodDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: JuselColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.payment, color: JuselColors.primaryColor(context)),
            const SizedBox(width: 8),
            const Text('Payment Method'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PaymentMethodOption(
              icon: Icons.money,
              label: 'Cash',
              value: 'cash',
              onTap: () => Navigator.of(context).pop('cash'),
            ),
            const SizedBox(height: JuselSpacing.s12),
            _PaymentMethodOption(
              icon: Icons.account_balance_wallet,
              label: 'Mobile Money',
              value: 'mobile_money',
              onTap: () => Navigator.of(context).pop('mobile_money'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        decoration: BoxDecoration(
          border: Border.all(color: JuselColors.border(context)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: JuselColors.primaryColor(context), size: 24),
            const SizedBox(width: JuselSpacing.s12),
            Text(
              label,
              style: JuselTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: JuselColors.mutedForeground(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDelete;

  const _CartItemCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: JuselSpacing.s12),
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: JuselColors.muted(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: JuselTextStyles.bodyLarge(context)),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  '${item.quantity} x GHS ${item.effectivePrice.toStringAsFixed(2)}',
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                  ),
                ),
                if (item.overrideReason != null) ...[
                  const SizedBox(height: JuselSpacing.s4),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: JuselColors.primaryColor(context),
                      ),
                      const SizedBox(width: JuselSpacing.s6),
                      Expanded(
                        child: Text(
                          'Override reason: ${item.overrideReason}',
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Text(
            'GHS ${item.total.toStringAsFixed(2)}',
            style: JuselTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: JuselSpacing.s8),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline,
              color: JuselColors.mutedForeground(context),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
