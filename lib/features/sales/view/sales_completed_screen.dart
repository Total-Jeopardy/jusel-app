import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/sales/models/cart_item.dart';

class SalesCompletedScreen extends StatelessWidget {
  final List<CartItem> items;
  final double subtotal;
  final String sellerName;
  final String paymentMethod;
  final String? receiptNumber;
  final DateTime dateTime;

  SalesCompletedScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.sellerName,
    required this.paymentMethod,
    String? receiptNumber,
    DateTime? dateTime,
  }) : receiptNumber = receiptNumber ?? _generateReceipt(),
       dateTime = dateTime ?? DateTime.now();

  static String _generateReceipt() {
    final rand = Random();
    final number = 1000 + rand.nextInt(9000);
    return '#S-$number';
  }

  @override
  Widget build(BuildContext context) {
    final total = subtotal; // tax is 0% in mock
    final tax = 0.0;
    return Scaffold(
      backgroundColor: JuselColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9FBE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: JuselColors.success),
              ),
              const SizedBox(height: JuselSpacing.s12),
              Text(
                'Sale Completed!',
                style: JuselTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: JuselSpacing.s6),
              Text(
                'Transaction has been recorded successfully.',
                style: JuselTextStyles.bodyMedium.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: JuselSpacing.s16),
              _ReceiptCard(
                receiptNumber: receiptNumber ?? '',
                dateTime: dateTime,
                sellerName: sellerName,
                paymentMethod: paymentMethod,
                items: items,
                subtotal: subtotal,
                tax: tax,
                total: total,
              ),
              const SizedBox(height: JuselSpacing.s12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.print_outlined),
                      label: const Text(
                        'Print',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: JuselSpacing.s12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: JuselColors.border),
                        backgroundColor: Colors.white,
                        foregroundColor: JuselColors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: JuselSpacing.s12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined),
                      label: const Text(
                        'Share',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: JuselSpacing.s12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: JuselColors.border),
                        backgroundColor: Colors.white,
                        foregroundColor: JuselColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s12),
              const _BossInsights(),
              const SizedBox(height: JuselSpacing.s16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    'Start New Sale',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s16,
                    ),
                    backgroundColor: JuselColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: JuselSpacing.s12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFFF4F7FB),
                    side: const BorderSide(color: Color(0xFFF4F7FB)),
                    foregroundColor: JuselColors.foreground,
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: JuselColors.mutedForeground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final String receiptNumber;
  final DateTime dateTime;
  final String sellerName;
  final String paymentMethod;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;

  const _ReceiptCard({
    required this.receiptNumber,
    required this.dateTime,
    required this.sellerName,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_monthLabel(dateTime.month)} ${dateTime.day}, ${_two(dateTime.hour)}:${_two(dateTime.minute)}';
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _LabelValue(label: 'RECEIPT NO', value: receiptNumber),
                _LabelValue(label: 'DATE', value: dateLabel, alignEnd: true),
              ],
            ),
            const SizedBox(height: JuselSpacing.s12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _LabelValue(label: 'SOLD BY', value: sellerName),
                _LabelValue(
                  label: 'PAYMENT',
                  value: paymentMethod,
                  alignEnd: true,
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s12),
            const Divider(height: 1, color: JuselColors.border),
            const SizedBox(height: JuselSpacing.s12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: JuselSpacing.s12),
                child: _ItemRow(item: item),
              ),
            ),
            const Divider(height: 1, color: JuselColors.border),
            const SizedBox(height: JuselSpacing.s12),
            _MoneyRow(label: 'Subtotal', amount: subtotal),
            const SizedBox(height: JuselSpacing.s6),
            _MoneyRow(label: 'Tax (0%)', amount: tax),
            const SizedBox(height: JuselSpacing.s16),
            _MoneyRow(
              label: 'Total Amount',
              amount: total,
              bold: true,
              color: JuselColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final overridden = item.overriddenPrice != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  item.productName,
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (overridden) ...[
                  const SizedBox(width: JuselSpacing.s6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: JuselSpacing.s6,
                      vertical: JuselSpacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Overridden',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.destructive,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              'GHS ${item.total.toStringAsFixed(2)}',
              style: JuselTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: JuselSpacing.s4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${item.quantity} x GHS ${item.effectivePrice.toStringAsFixed(2)}',
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (overridden)
              Text(
                'GHS ${item.unitPrice.toStringAsFixed(2)}',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;
  const _LabelValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: JuselTextStyles.bodySmall.copyWith(
            color: JuselColors.mutedForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: JuselSpacing.s4),
        Text(
          value,
          style: JuselTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  final Color? color;

  const _MoneyRow({
    required this.label,
    required this.amount,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: JuselTextStyles.bodyMedium.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        Text(
          'GHS ${amount.toStringAsFixed(2)}',
          style: JuselTextStyles.bodyMedium.copyWith(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: color ?? JuselColors.foreground,
          ),
        ),
      ],
    );
  }
}

class _BossInsights extends StatelessWidget {
  const _BossInsights();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7E5B5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: JuselSpacing.s8,
              vertical: JuselSpacing.s6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bar_chart,
                  color: JuselColors.primary,
                  size: 18,
                ),
                const SizedBox(width: JuselSpacing.s6),
                Text(
                  'Boss Insights',
                  style: JuselTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Cost',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'GHS 8.20',
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(width: JuselSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Profit',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '+GHS 6.30',
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: JuselColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
