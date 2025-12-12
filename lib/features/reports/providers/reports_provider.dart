import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/services/reports_service.dart';
import 'package:jusel_app/features/reports/models/report_models.dart';
import 'package:jusel_app/features/dashboard/providers/period_filter_provider.dart';
import 'package:jusel_app/features/reports/providers/report_filters_provider.dart';

final reportsServiceProvider = Provider<ReportsService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReportsService(db);
});

/// Price overrides/discounts report provider
final priceOverridesProvider = FutureProvider.autoDispose
    .family<List<PriceOverrideEntry>, DateTimeRange>((ref, period) async {
      final service = ref.watch(reportsServiceProvider);
      final filters = ref.watch(reportFiltersProvider);
      return service.getPriceOverrides(
        period: period,
        productId: filters.productId,
        userId: filters.userId,
      );
    });

/// Stock alerts (low stock/stock-out) report provider
final stockAlertsProvider = FutureProvider.autoDispose
    .family<List<StockAlertEntry>, DateTimeRange>((ref, period) async {
      final service = ref.watch(reportsServiceProvider);
      final filters = ref.watch(reportFiltersProvider);
      final settingsService = await ref.watch(settingsServiceProvider.future);
      final lowStockThreshold = await settingsService.getLowStockThreshold();
      return service.getStockAlerts(
        period: period,
        productId: filters.productId,
        category: filters.category,
        lowStockThreshold: lowStockThreshold,
      );
    });

/// Production batch efficiency report provider
final productionBatchEfficiencyProvider = FutureProvider.autoDispose
    .family<List<ProductionBatchEfficiency>, DateTimeRange>((
      ref,
      period,
    ) async {
      final service = ref.watch(reportsServiceProvider);
      final filters = ref.watch(reportFiltersProvider);
      return service.getProductionBatchEfficiency(
        period: period,
        productId: filters.productId,
      );
    });

// Pure helper provider to get date range from period filter state
final dateRangeForPeriodProvider = Provider<DateTimeRange>((ref) {
  final state = ref.watch(periodFilterProvider);

  if (state.filter == PeriodFilter.custom && state.customRange != null) {
    return state.customRange!;
  }

  // Default to computed range for the current filter; this value stays stable
  // until the user changes the period, avoiding new DateTimeRange instances
  // on every rebuild.
  return PeriodFilterHelper.getDateRangeForFilter(state.filter);
});

final salesReportProvider = FutureProvider.autoDispose<SalesReport>((
  ref,
) async {
  final service = ref.watch(reportsServiceProvider);
  final dateRange = ref.watch(dateRangeForPeriodProvider);
  final filters = ref.watch(reportFiltersProvider);

  // Keep alive for caching - providers auto-invalidate when dependencies change
  ref.keepAlive();

  return await service.generateSalesReport(
    period: dateRange,
    productId: filters.productId,
    category: filters.category,
    paymentMethod: filters.paymentMethod,
    userId: filters.userId,
  );
});

final topProductsBySalesProvider =
    FutureProvider.autoDispose<List<ProductSalesMetric>>((ref) async {
      final service = ref.watch(reportsServiceProvider);
      final dateRange = ref.watch(dateRangeForPeriodProvider);
      final filters = ref.watch(reportFiltersProvider);
      return await service.getTopProductsBySales(
        period: dateRange,
        limit: 10,
        productId: filters.productId,
        category: filters.category,
        paymentMethod: filters.paymentMethod,
        userId: filters.userId,
      );
    });

final topProductsByProfitProvider =
    FutureProvider.autoDispose<List<ProductSalesMetric>>((ref) async {
      final service = ref.watch(reportsServiceProvider);
      final dateRange = ref.watch(dateRangeForPeriodProvider);
      final filters = ref.watch(reportFiltersProvider);

      // Keep alive for caching
      ref.keepAlive();

      return await service.getTopProductsByProfit(
        period: dateRange,
        limit: 10,
        productId: filters.productId,
        category: filters.category,
        paymentMethod: filters.paymentMethod,
        userId: filters.userId,
      );
    });

final paymentMethodBreakdownProvider =
    FutureProvider.autoDispose<Map<String, double>>((ref) async {
      final service = ref.watch(reportsServiceProvider);
      final dateRange = ref.watch(dateRangeForPeriodProvider);
      final filters = ref.watch(reportFiltersProvider);

      // Keep alive for caching
      ref.keepAlive();

      return await service.getSalesByPaymentMethod(
        period: dateRange,
        productId: filters.productId,
        category: filters.category,
        paymentMethod: filters.paymentMethod,
        userId: filters.userId,
      );
    });

final dailyBreakdownProvider =
    FutureProvider.autoDispose<List<DailySalesMetric>>((ref) async {
      final service = ref.watch(reportsServiceProvider);
      final dateRange = ref.watch(dateRangeForPeriodProvider);
      final filters = ref.watch(reportFiltersProvider);

      // Keep alive for caching
      ref.keepAlive();

      return await service.getDailyBreakdown(
        period: dateRange,
        productId: filters.productId,
        category: filters.category,
        paymentMethod: filters.paymentMethod,
        userId: filters.userId,
      );
    });

final categoryContributionProvider =
    FutureProvider.autoDispose<Map<String, CategoryMetrics>>((ref) async {
      final service = ref.watch(reportsServiceProvider);
      final dateRange = ref.watch(dateRangeForPeriodProvider);
      final filters = ref.watch(reportFiltersProvider);

      // Keep alive for caching
      ref.keepAlive();

      return await service.getCategoryContribution(
        period: dateRange,
        productId: filters.productId,
        category: filters.category,
        paymentMethod: filters.paymentMethod,
        userId: filters.userId,
      );
    });

final paymentMethodTrendsProvider =
    FutureProvider.autoDispose<Map<DateTime, Map<String, double>>>((ref) async {
      final service = ref.watch(reportsServiceProvider);
      final dateRange = ref.watch(dateRangeForPeriodProvider);
      final filters = ref.watch(reportFiltersProvider);

      // Keep alive for caching
      ref.keepAlive();

      return await service.getPaymentMethodTrends(
        period: dateRange,
        productId: filters.productId,
        category: filters.category,
        paymentMethod: filters.paymentMethod,
        userId: filters.userId,
      );
    });
