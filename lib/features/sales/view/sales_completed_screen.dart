import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jusel_app/features/dashboard/view/apprentice_dashboard.dart';
import 'package:jusel_app/features/dashboard/view/boss_dashboard.dart';
import 'package:jusel_app/features/sales/models/cart_item.dart';
import 'package:jusel_app/features/sales/providers/cart_provider.dart';
import 'package:jusel_app/features/sales/view/sales_screen.dart';

class SalesCompletedScreen extends ConsumerStatefulWidget {
  final List<CartItem> items;
  final double subtotal;
  final double netProfit;
  final String sellerName;
  final String paymentMethod;
  final String? receiptNumber;
  final DateTime dateTime;

  SalesCompletedScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.netProfit,
    required this.sellerName,
    required this.paymentMethod,
    String? receiptNumber,
    DateTime? dateTime,
  })  : receiptNumber = receiptNumber ?? _generateReceipt(),
        dateTime = dateTime ?? DateTime.now();

  static String _generateReceipt() {
    final rand = Random();
    final number = 1000 + rand.nextInt(9000);
    return '#S-$number';
  }

  @override
  ConsumerState<SalesCompletedScreen> createState() =>
      _SalesCompletedScreenState();
}

class _SalesCompletedScreenState extends ConsumerState<SalesCompletedScreen> {
  bool _printing = false;
  bool _sharing = false;

  String get _receiptNumber => widget.receiptNumber ?? '';
  double get _tax => 0.0; // placeholder
  double get _total => widget.subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuselColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: JuselColors.successColor(context).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: JuselColors.successColor(context)),
              ),
              const SizedBox(height: JuselSpacing.s12),
              Text(
                'Sale Completed!',
                style: JuselTextStyles.headlineMedium(context).copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: JuselSpacing.s6),
              Text(
                'Transaction has been recorded successfully.',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: JuselSpacing.s16),
              _ReceiptCard(
                receiptNumber: _receiptNumber,
                dateTime: widget.dateTime,
                sellerName: widget.sellerName,
                paymentMethod: widget.paymentMethod,
                items: widget.items,
                subtotal: widget.subtotal,
                tax: _tax,
                total: _total,
              ),
              const SizedBox(height: JuselSpacing.s12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _printing ? null : _handlePrint,
                      icon: const Icon(Icons.print_outlined),
                      label: _printing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
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
                        side: BorderSide(color: JuselColors.border(context)),
                        backgroundColor: JuselColors.card(context),
                        foregroundColor: JuselColors.foreground(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: JuselSpacing.s12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sharing ? null : _handleShare,
                      icon: const Icon(Icons.share_outlined),
                      label: _sharing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
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
                        side: BorderSide(color: JuselColors.border(context)),
                        backgroundColor: JuselColors.card(context),
                        foregroundColor: JuselColors.foreground(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s12),
              _BossInsights(total: _total, netProfit: widget.netProfit),
              const SizedBox(height: JuselSpacing.s16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(cartProvider.notifier).clearCart();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SalesScreen()),
                      (route) => route.isFirst,
                    );
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
                    backgroundColor: JuselColors.primaryColor(context),
                    foregroundColor: JuselColors.primaryForeground,
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
                    final user = ref.read(authViewModelProvider).valueOrNull;
                    final isBoss = user?.role == 'boss';
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => isBoss
                            ? const BossDashboard()
                            : const ApprenticeDashboard(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: JuselColors.muted(context),
                    side: BorderSide(color: JuselColors.border(context)),
                    foregroundColor: JuselColors.foreground(context),
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: JuselColors.mutedForeground(context),
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

  Future<void> _handlePrint() async {
    setState(() => _printing = true);
    try {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Receipt $_receiptNumber',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.SizedBox(height: 8),
              pw.Text('Date: ${widget.dateTime}'),
              pw.Text('Seller: ${widget.sellerName}'),
              pw.Text('Payment: ${widget.paymentMethod}'),
              pw.SizedBox(height: 12),
              pw.Text('Items', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              ...widget.items.map(
                (item) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(item.productName),
                        pw.Text('GHS ${item.total.toStringAsFixed(2)}'),
                      ],
                    ),
                    pw.Text(
                      '${item.quantity} x GHS ${item.effectivePrice.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 4),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal'),
                  pw.Text('GHS ${widget.subtotal.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tax'),
                  pw.Text('GHS ${_tax.toStringAsFixed(2)}'),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('GHS ${_total.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      );

      final Uint8List data = await doc.save();
      await Printing.layoutPdf(onLayout: (_) async => data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Future<void> _handleShare() async {
    setState(() => _sharing = true);
    try {
      final receipt = _buildReceiptText();
      await Share.share(receipt, subject: 'Receipt $_receiptNumber');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  String _buildReceiptText() {
    final buffer = StringBuffer();
    buffer.writeln('Receipt $_receiptNumber');
    buffer.writeln('Date: ${widget.dateTime}');
    buffer.writeln('Seller: ${widget.sellerName}');
    buffer.writeln('Payment: ${widget.paymentMethod}');
    buffer.writeln('');
    buffer.writeln('Items:');
    for (final item in widget.items) {
      buffer.writeln(
          '- ${item.productName} x${item.quantity} @ GHS ${item.effectivePrice.toStringAsFixed(2)} = GHS ${item.total.toStringAsFixed(2)}');
    }
    buffer.writeln('');
    buffer.writeln('Subtotal: GHS ${widget.subtotal.toStringAsFixed(2)}');
    buffer.writeln('Tax: GHS ${_tax.toStringAsFixed(2)}');
    buffer.writeln('Total: GHS ${_total.toStringAsFixed(2)}');
    return buffer.toString();
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
            Divider(height: 1, color: JuselColors.border(context)),
            const SizedBox(height: JuselSpacing.s12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: JuselSpacing.s12),
                child: _ItemRow(item: item),
              ),
            ),
            Divider(height: 1, color: JuselColors.border(context)),
            const SizedBox(height: JuselSpacing.s12),
            _MoneyRow(label: 'Subtotal', amount: subtotal),
            const SizedBox(height: JuselSpacing.s6),
            _MoneyRow(label: 'Tax (0%)', amount: tax),
            const SizedBox(height: JuselSpacing.s16),
            _MoneyRow(
              label: 'Total Amount',
              amount: total,
              bold: true,
              color: JuselColors.primaryColor(context),
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
    final hasReason = item.overrideReason != null && item.overrideReason!.isNotEmpty;
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
                  style: JuselTextStyles.bodyMedium(context).copyWith(
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
                      color: JuselColors.destructiveColor(context).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Overridden',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.destructiveColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              'GHS ${item.total.toStringAsFixed(2)}',
              style: JuselTextStyles.bodyMedium(context).copyWith(
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
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (overridden)
              Text(
                'GHS ${item.unitPrice.toStringAsFixed(2)}',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        if (hasReason) ...[
          const SizedBox(height: JuselSpacing.s4),
          Row(
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: 14,
                color: JuselColors.primaryColor(context),
              ),
              const SizedBox(width: JuselSpacing.s6),
              Expanded(
                child: Text(
                  'Reason: ${item.overrideReason}',
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
          style: JuselTextStyles.bodySmall(context).copyWith(
            color: JuselColors.mutedForeground(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: JuselSpacing.s4),
        Text(
          value,
          style: JuselTextStyles.bodyMedium(context).copyWith(
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
          style: JuselTextStyles.bodyMedium(context).copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        Text(
          'GHS ${amount.toStringAsFixed(2)}',
          style: JuselTextStyles.bodyMedium(context).copyWith(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: color ?? JuselColors.foreground(context),
          ),
        ),
      ],
    );
  }
}

class _BossInsights extends StatelessWidget {
  final double total;
  final double netProfit;
  const _BossInsights({required this.total, required this.netProfit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: JuselColors.warningColor(context).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.warningColor(context).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: JuselSpacing.s8,
              vertical: JuselSpacing.s6,
            ),
            decoration: BoxDecoration(
              color: JuselColors.card(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: JuselColors.primaryColor(context),
                  size: 18,
                ),
                const SizedBox(width: JuselSpacing.s6),
                Text(
                  'Boss Insights',
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground(context),
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
                'Total Amount',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'GHS ${total.toStringAsFixed(2)}',
                style: JuselTextStyles.bodyMedium(context).copyWith(
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
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'GHS ${netProfit.toStringAsFixed(2)}',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w800,
                  color: netProfit >= 0 ? JuselColors.successColor(context) : JuselColors.destructiveColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
