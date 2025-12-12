import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:jusel_app/features/reports/models/report_models.dart';

/// Service for exporting reports to CSV and PDF formats
class ReportsExportService {
  /// Export sales report to CSV
  Future<String> exportToCSV({
    required SalesReport report,
    required DateTimeRange period,
    String? productFilter,
    String? categoryFilter,
    String? paymentMethodFilter,
    String? userFilter,
  }) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Sales Report');
    buffer.writeln('Period: ${DateFormat('yyyy-MM-dd').format(period.start)} to ${DateFormat('yyyy-MM-dd').format(period.end)}');
    buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    
    // Filter information
    final filters = <String>[];
    if (productFilter != null) filters.add('Product: $productFilter');
    if (categoryFilter != null) filters.add('Category: $categoryFilter');
    if (paymentMethodFilter != null) filters.add('Payment: ${_formatPaymentMethod(paymentMethodFilter)}');
    if (userFilter != null) filters.add('Staff: $userFilter');
    if (filters.isNotEmpty) {
      buffer.writeln('Filters: ${filters.join(', ')}');
    }
    buffer.writeln('');

    // Summary
    buffer.writeln('Summary');
    buffer.writeln('Total Sales,GHS ${report.totalSales.toStringAsFixed(2)}');
    buffer.writeln('Total Profit,GHS ${report.totalProfit.toStringAsFixed(2)}');
    buffer.writeln('Profit Margin,${report.profitMargin.toStringAsFixed(2)}%');
    buffer.writeln('Total Transactions,${report.totalTransactions}');
    buffer.writeln('');

    // Payment Method Breakdown
    buffer.writeln('Payment Method Breakdown');
    buffer.writeln('Method,Amount,Percentage,Transactions');
    report.salesByPaymentMethod.forEach((method, amount) {
      final percentage = report.totalSales > 0
          ? (amount / report.totalSales) * 100
          : 0.0;
      final transactions = report.transactionsByPaymentMethod[method] ?? 0;
      buffer.writeln('${_formatPaymentMethod(method)},GHS ${amount.toStringAsFixed(2)},${percentage.toStringAsFixed(2)}%,$transactions');
    });
    buffer.writeln('');

    // Top Products
    buffer.writeln('Top Products by Sales');
    buffer.writeln('Rank,Product Name,Quantity Sold,Revenue,Profit,Profit Margin');
    for (int i = 0; i < report.topProducts.length; i++) {
      final product = report.topProducts[i];
      buffer.writeln('${i + 1},${product.productName},${product.quantitySold},GHS ${product.revenue.toStringAsFixed(2)},GHS ${product.profit.toStringAsFixed(2)},${product.profitMargin.toStringAsFixed(2)}%');
    }
    buffer.writeln('');

    // Daily Breakdown
    buffer.writeln('Daily Breakdown');
    buffer.writeln('Date,Sales,Profit,Transactions');
    for (final daily in report.dailyBreakdown) {
      buffer.writeln('${DateFormat('yyyy-MM-dd').format(daily.date)},GHS ${daily.sales.toStringAsFixed(2)},GHS ${daily.profit.toStringAsFixed(2)},${daily.transactions}');
    }
    buffer.writeln('');

    // Product Breakdown
    buffer.writeln('All Products Breakdown');
    buffer.writeln('Product Name,Quantity Sold,Revenue,Profit,Profit Margin');
    for (final product in report.productBreakdown) {
      buffer.writeln('${product.productName},${product.quantitySold},GHS ${product.revenue.toStringAsFixed(2)},GHS ${product.profit.toStringAsFixed(2)},${product.profitMargin.toStringAsFixed(2)}%');
    }

    // Write to file
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/sales_report_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    return file.absolute.path;
  }

  /// Export sales report to PDF
  Future<String> exportToPDF({
    required SalesReport report,
    required DateTimeRange period,
    String? productFilter,
    String? categoryFilter,
    String? paymentMethodFilter,
    String? userFilter,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Text(
              'Sales Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Period: ${DateFormat('MMM dd, yyyy').format(period.start)} - ${DateFormat('MMM dd, yyyy').format(period.end)}',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          // Filter information
          if (productFilter != null || categoryFilter != null || paymentMethodFilter != null || userFilter != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Filters: ${[
                if (productFilter != null) 'Product: $productFilter',
                if (categoryFilter != null) 'Category: $categoryFilter',
                if (paymentMethodFilter != null) 'Payment: ${_formatPaymentMethod(paymentMethodFilter)}',
                if (userFilter != null) 'Staff: $userFilter',
              ].join(', ')}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic),
            ),
          ],
          pw.SizedBox(height: 30),

          // Summary Cards
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard('Total Sales', 'GHS ${report.totalSales.toStringAsFixed(2)}'),
              _buildSummaryCard('Total Profit', 'GHS ${report.totalProfit.toStringAsFixed(2)}'),
              _buildSummaryCard('Transactions', '${report.totalTransactions}'),
              _buildSummaryCard('Profit Margin', '${report.profitMargin.toStringAsFixed(1)}%'),
            ],
          ),
          pw.SizedBox(height: 30),

          // Payment Method Breakdown
          pw.Text(
            'Payment Method Breakdown',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Method', isHeader: true),
                  _buildTableCell('Amount', isHeader: true),
                  _buildTableCell('Percentage', isHeader: true),
                  _buildTableCell('Transactions', isHeader: true),
                ],
              ),
              ...report.salesByPaymentMethod.entries.map((entry) {
                final percentage = report.totalSales > 0
                    ? (entry.value / report.totalSales) * 100
                    : 0.0;
                final transactions = report.transactionsByPaymentMethod[entry.key] ?? 0;
                return pw.TableRow(
                  children: [
                    _buildTableCell(_formatPaymentMethod(entry.key)),
                    _buildTableCell('GHS ${entry.value.toStringAsFixed(2)}'),
                    _buildTableCell('${percentage.toStringAsFixed(1)}%'),
                    _buildTableCell('$transactions'),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 30),

          // Top Products
          pw.Text(
            'Top Products by Sales',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Rank', isHeader: true),
                  _buildTableCell('Product', isHeader: true),
                  _buildTableCell('Qty', isHeader: true),
                  _buildTableCell('Revenue', isHeader: true),
                  _buildTableCell('Profit', isHeader: true),
                  _buildTableCell('Margin', isHeader: true),
                ],
              ),
              ...report.topProducts.asMap().entries.map((entry) {
                final product = entry.value;
                return pw.TableRow(
                  children: [
                    _buildTableCell('${entry.key + 1}'),
                    _buildTableCell(product.productName),
                    _buildTableCell('${product.quantitySold}'),
                    _buildTableCell('GHS ${product.revenue.toStringAsFixed(2)}'),
                    _buildTableCell('GHS ${product.profit.toStringAsFixed(2)}'),
                    _buildTableCell('${product.profitMargin.toStringAsFixed(1)}%'),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 30),

          // Daily Breakdown (limit to 30 days for PDF readability)
          pw.Text(
            'Daily Breakdown',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Date', isHeader: true),
                  _buildTableCell('Sales', isHeader: true),
                  _buildTableCell('Profit', isHeader: true),
                  _buildTableCell('Transactions', isHeader: true),
                ],
              ),
              ...report.dailyBreakdown.take(30).map((daily) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(DateFormat('MMM dd').format(daily.date)),
                    _buildTableCell('GHS ${daily.sales.toStringAsFixed(2)}'),
                    _buildTableCell('GHS ${daily.profit.toStringAsFixed(2)}'),
                    _buildTableCell('${daily.transactions}'),
                  ],
                );
              }),
            ],
          ),
          if (report.dailyBreakdown.length > 30)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Text(
                'Showing first 30 of ${report.dailyBreakdown.length} days',
                style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
              ),
            ),
        ],
      ),
    );

    // Save to file
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/sales_report_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file.absolute.path;
  }

  /// Share exported file
  Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        subject: subject ?? 'Sales Report',
      );
      // Note: share_plus doesn't provide status information in all versions
      // If sharing fails, it will throw an exception which we catch below
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      if (e.code == 'no_activity' || e.message?.contains('No Activity found') == true) {
        throw Exception('No sharing options available. Please install a file manager or sharing app.');
      }
      throw Exception('Failed to share file: ${e.message ?? e.toString()}');
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to share file: ${e.toString()}');
    }
  }

  /// Export and share CSV
  Future<void> exportAndShareCSV({
    required SalesReport report,
    required DateTimeRange period,
    String? productFilter,
    String? categoryFilter,
    String? paymentMethodFilter,
    String? userFilter,
  }) async {
    final filePath = await exportToCSV(
      report: report,
      period: period,
      productFilter: productFilter,
      categoryFilter: categoryFilter,
      paymentMethodFilter: paymentMethodFilter,
      userFilter: userFilter,
    );
    await shareFile(filePath, subject: 'Sales Report (CSV)');
  }

  /// Export and share PDF
  Future<void> exportAndSharePDF({
    required SalesReport report,
    required DateTimeRange period,
    String? productFilter,
    String? categoryFilter,
    String? paymentMethodFilter,
    String? userFilter,
  }) async {
    final filePath = await exportToPDF(
      report: report,
      period: period,
      productFilter: productFilter,
      categoryFilter: categoryFilter,
      paymentMethodFilter: paymentMethodFilter,
      userFilter: userFilter,
    );
    await shareFile(filePath, subject: 'Sales Report (PDF)');
  }

  // Helper methods
  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'mobile_money':
        return 'Mobile Money';
      case 'card':
        return 'Card';
      case 'transfer':
        return 'Bank Transfer';
      case 'pos':
        return 'POS';
      default:
        return method;
    }
  }

  pw.Widget _buildSummaryCard(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}

