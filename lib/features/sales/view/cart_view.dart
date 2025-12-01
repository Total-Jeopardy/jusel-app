import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/sales/models/cart_item.dart';
import 'package:jusel_app/features/sales/providers/cart_provider.dart';

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
              color: JuselColors.mutedForeground,
            ),
            const SizedBox(height: JuselSpacing.s16),
            Text(
              'Your cart is empty',
              style: JuselTextStyles.bodyMedium.copyWith(
                color: JuselColors.mutedForeground,
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
                style: JuselTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: JuselSpacing.s8),
              Text(
                '${cart.itemCount} items',
                style: JuselTextStyles.bodyMedium.copyWith(
                  color: JuselColors.mutedForeground,
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
            color: Colors.white,
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
                  Text(
                    'Total Amount',
                    style: JuselTextStyles.bodyLarge,
                  ),
                  Text(
                    'GHS ${cart.totalAmount.toStringAsFixed(2)}',
                    style: JuselTextStyles.headlineMedium.copyWith(
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
                    backgroundColor: const Color(0xFF1ECB7F),
                    foregroundColor: Colors.white,
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
                        style: JuselTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: JuselSpacing.s8),
                      const Icon(Icons.arrow_forward, size: 20),
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

  Future<void> _handleFinalizeSale(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final cart = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final salesService = ref.read(salesServiceProvider);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to make a sale'),
          ),
        );
      }
      return;
    }

    if (cart.items.isEmpty) {
      return;
    }

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      // Process each item in the cart
      for (final item in cart.items) {
        await salesService.sellProduct(
          productId: item.productId,
          quantity: item.quantity,
          createdByUserId: user.uid,
          overriddenPrice: item.overriddenPrice,
        );
      }

      // Clear cart after successful sale
      cartNotifier.clearCart();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sale finalized successfully!'),
            backgroundColor: JuselColors.success,
          ),
        );
        // Navigate back or refresh
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: JuselColors.destructive,
          ),
        );
      }
    }
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: JuselSpacing.s12),
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: JuselTextStyles.bodyLarge,
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  '${item.quantity} x GHS ${item.effectivePrice.toStringAsFixed(2)}',
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'GHS ${item.total.toStringAsFixed(2)}',
            style: JuselTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: JuselSpacing.s8),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline,
              color: JuselColors.mutedForeground,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

