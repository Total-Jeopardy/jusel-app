import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class PendingItemsScreen extends StatelessWidget {
  const PendingItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _mockItems();
    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pending Items',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF4CE),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: JuselSpacing.s8),
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: Color(0xFFDAA200),
                    ),
                  ),
                  Text(
                    'Offline Mode',
                    style: JuselTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDAA200),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _InfoBanner(
                      text:
                          'These operations are saved locally. Jusel will automatically attempt to sync them once an internet connection is detected.',
                    ),
                    const SizedBox(height: JuselSpacing.s16),
                    Text(
                      'WAITING TO SYNC (${items.length})',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    ...items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: JuselSpacing.s12,
                            ),
                            child: _PendingCard(item: item),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: JuselColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.sync),
                  label: const Text(
                    'Sync All Now',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_PendingItem> _mockItems() => const [
    _PendingItem(
      title: 'Sale #1025',
      subtitle: '2 mins ago • 3 items',
      icon: Icons.shopping_bag_outlined,
      badgeColor: Color(0xFFE9F0FF),
      badgeIconColor: JuselColors.primary,
      status: _PendingStatus.queued,
    ),
    _PendingItem(
      title: 'Price Update: Milk 1L',
      subtitle: '15 mins ago • \$2.50 → \$2.80',
      icon: Icons.local_offer_outlined,
      badgeColor: Color(0xFFFFEDEB),
      badgeIconColor: JuselColors.destructive,
      status: _PendingStatus.retrying,
    ),
    _PendingItem(
      title: 'Production Batch #553',
      subtitle: '45 mins ago • Bakery',
      icon: Icons.factory_outlined,
      badgeColor: Color(0xFFF0ECFF),
      badgeIconColor: Color(0xFF7C5CFF),
      status: _PendingStatus.queued,
    ),
    _PendingItem(
      title: 'Stock Adjustment',
      subtitle: '1 hr ago • Inventory Check',
      icon: Icons.inventory_2_outlined,
      badgeColor: Color(0xFFE8F5F0),
      badgeIconColor: Color(0xFF16A34A),
      status: _PendingStatus.queued,
    ),
  ];
}

class _PendingCard extends StatelessWidget {
  final _PendingItem item;
  const _PendingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusLabel = item.status == _PendingStatus.retrying
        ? 'RETRYING'
        : 'QUEUED';
    final statusColor = item.status == _PendingStatus.retrying
        ? const Color(0xFFF97316)
        : JuselColors.mutedForeground;
    final statusBg = item.status == _PendingStatus.retrying
        ? const Color(0xFFFFF4E7)
        : const Color(0xFFF1F5F9);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border),
      ),
      padding: const EdgeInsets.all(JuselSpacing.s12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.badgeIconColor),
          ),
          const SizedBox(width: JuselSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  item.subtitle,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: JuselSpacing.s12,
              vertical: JuselSpacing.s6,
            ),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusLabel,
              style: JuselTextStyles.bodySmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: JuselColors.primary),
          const SizedBox(width: JuselSpacing.s8),
          Expanded(
            child: Text(
              text,
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color badgeColor;
  final Color badgeIconColor;
  final _PendingStatus status;

  const _PendingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeColor,
    required this.badgeIconColor,
    required this.status,
  });
}

enum _PendingStatus { queued, retrying }
