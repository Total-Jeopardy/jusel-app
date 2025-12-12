import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/stock/view/stock_detail_screen.dart';

final userActivityProvider = FutureProvider.autoDispose
    .family<List<StockMovementsTableData>, String>((ref, userId) async {
  final db = ref.read(appDatabaseProvider);
  final movements = await db.stockMovementsDao.getMovementsForUser(userId);
  return movements;
});

class UserActivityScreen extends ConsumerWidget {
  final String userId;
  final String userName;

  const UserActivityScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(userActivityProvider(userId));

    return Scaffold(
      backgroundColor: JuselColors.background(context),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Text(
          '$userName\'s Activity',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
      ),
      body: SafeArea(
        child: activityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(JuselSpacing.s16),
              child: Text(
                'Failed to load activity: $e',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  color: JuselColors.destructiveColor(context),
                ),
              ),
            ),
          ),
          data: (movements) {
            if (movements.isEmpty) {
              return Center(
                child: Text(
                  'No activity found',
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(JuselSpacing.s16),
              itemCount: movements.length,
              itemBuilder: (context, index) {
                final movement = movements[index];
                final isPositive = movement.type.toLowerCase() == 'stock_in' ||
                    movement.type.toLowerCase() == 'production_output';
                final icon = isPositive
                    ? Icons.add_circle_outline
                    : Icons.remove_circle_outline;
                final color = isPositive
                    ? JuselColors.primaryColor(context)
                    : JuselColors.destructiveColor(context);

                return Card(
                  margin: const EdgeInsets.only(bottom: JuselSpacing.s12),
                  child: ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(
                      movement.type.replaceAll('_', ' ').toUpperCase(),
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Quantity: ${movement.quantityUnits} units',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                    trailing: Text(
                      DateFormat('MMM d, y • h:mm a').format(movement.createdAt),
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StockDetailScreen(
                            productId: movement.productId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

