import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import 'package:jusel_app/core/database/app_database.dart';

import 'package:jusel_app/core/providers/database_provider.dart';

import 'package:jusel_app/core/utils/theme.dart';

import 'package:jusel_app/features/dashboard/providers/period_filter_provider.dart';

import 'package:jusel_app/features/reports/models/report_models.dart';

import 'package:jusel_app/features/reports/providers/reports_provider.dart';
import 'package:jusel_app/features/reports/providers/report_filters_provider.dart';
import 'package:jusel_app/core/services/reports_export_service.dart';
import 'package:jusel_app/core/ui/components/jusel_card.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

// Reusable providers for drill-down queries

final _productByIdProvider = FutureProvider.autoDispose
    .family<ProductsTableData?, String>((ref, id) async {
      final db = ref.read(appDatabaseProvider);

      return db.productsDao.getProduct(id);
    });

// Cached providers for filter dropdowns
final _productsForFiltersProvider =
    FutureProvider.autoDispose<List<ProductsTableData>>((ref) async {
      final db = ref.read(appDatabaseProvider);
      ref.keepAlive(); // Cache products list
      return db.productsDao.getAllProducts();
    });

final _usersForFiltersProvider =
    FutureProvider.autoDispose<List<UsersTableData>>((ref) async {
      final db = ref.read(appDatabaseProvider);
      ref.keepAlive(); // Cache users list
      return db.usersDao.getAllUsers();
    });

final _salesForDayProvider = FutureProvider.autoDispose
    .family<List<StockMovementsTableData>, DateTime>((ref, date) async {
      final dayStart = DateTime(date.year, date.month, date.day);

      final dayEnd = dayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      final db = ref.read(appDatabaseProvider);

      return db.stockMovementsDao.getSalesByDateRange(
        startDate: dayStart,

        endDate: dayEnd,
      );
    });

class _PaymentSalesQuery {
  final DateTimeRange range;

  final String method;

  const _PaymentSalesQuery({required this.range, required this.method});
}

final _salesForPaymentProvider = FutureProvider.autoDispose
    .family<List<StockMovementsTableData>, _PaymentSalesQuery>((
      ref,
      query,
    ) async {
      final db = ref.read(appDatabaseProvider);

      return db.stockMovementsDao.getSalesByDateRange(
        startDate: query.range.start,

        endDate: query.range.end,
        paymentMethod: query.method,
      );
    });

Color _paymentColor(BuildContext context, String method, int index) {
  final scheme = Theme.of(context).colorScheme;

  switch (method) {
    case 'cash':
      return scheme.primary;

    case 'mobile_money':
      return JuselColors.secondaryColor(context);

    case 'card':
      return JuselColors.accentColor(context);

    case 'transfer':
      return JuselColors.accentColor(context).withOpacity(0.85);

    case 'pos':
      return JuselColors.successColor(context);

    default:
      final colors = [
        JuselColors.warningColor(context),
        JuselColors.destructiveColor(context),
        JuselColors.accentColor(context),
        scheme.primary.withOpacity(0.85),
      ];

      return colors[index % colors.length];
  }
}

String _paymentLabel(String method) {
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
      return method.isNotEmpty ? method : 'Other';
  }
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  void _showProductDetails(BuildContext context, ProductSalesMetric product) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) => _ProductDetailsSheet(product: product),
    );
  }

  void _showDayDetails(BuildContext context, DailySalesMetric daily) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) => _DayDetailsSheet(daily: daily),
    );
  }

  void _showPaymentMethodDetails(
    BuildContext context,

    String method,

    double amount,

    DateTimeRange period,
  ) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) => _PaymentMethodDetailsSheet(
        method: method,

        amount: amount,

        period: period,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodFilterState = ref.watch(periodFilterProvider);

    final reportAsync = ref.watch(salesReportProvider);

    return Scaffold(
      backgroundColor: JuselColors.background(context),

      body: SafeArea(
        child: reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: JuselColors.destructiveColor(context),
                ),

                const SizedBox(height: 16),

                Text(
                  'Error loading report',

                  style: JuselTextStyles.headlineSmall(context),
                ),

                const SizedBox(height: 8),

                Text(
                  error.toString(),

                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                  ),

                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () => ref.invalidate(salesReportProvider),

                  child: const Text('Retry'),
                ),
              ],
            ),
          ),

          data: (report) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      periodFilterState: periodFilterState,
                      onPeriodChanged: (filter) {
                        ref.read(periodFilterProvider.notifier).setFilter(filter);
                      },
                      onCustomRangeSelected: (range) {
                        ref
                            .read(periodFilterProvider.notifier)
                            .setCustomRange(range);
                      },
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    _DimensionFilters(),
                    const SizedBox(height: JuselSpacing.s20),
                    _SummaryCards(report: report),
                    const SizedBox(height: JuselSpacing.s20),

                    _PaymentMethodBreakdown(
                      report: report,
                      onMethodTap: (method, amount) {
                        final dateRange = ref.read(dateRangeForPeriodProvider);
                        _showPaymentMethodDetails(
                          context,
                          method,
                          amount,
                          dateRange,
                        );
                      },
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    _TopProductsTable(
                      report: report,
                      onProductTap: (product) =>
                          _showProductDetails(context, product),
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    _DailyBreakdownChart(
                      report: report,
                      onDayTap: (daily) => _showDayDetails(context, daily),
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    _ProductBreakdownList(report: report),
                    const SizedBox(height: JuselSpacing.s20),
                    _CategoryContributionSection(),
                    const SizedBox(height: JuselSpacing.s20),
                    _PaymentMethodTrendsSection(),
                    const SizedBox(height: JuselSpacing.s20),
                    _PriceOverridesSection(),
                    const SizedBox(height: JuselSpacing.s20),
                    _StockAlertsSection(),
                    const SizedBox(height: JuselSpacing.s20),
                    _ProductionBatchEfficiencySection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final PeriodFilterState periodFilterState;

  final void Function(PeriodFilter) onPeriodChanged;

  final void Function(DateTimeRange) onCustomRangeSelected;

  const _Header({
    required this.periodFilterState,

    required this.onPeriodChanged,

    required this.onCustomRangeSelected,
  });

  void _showExportMenu(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.read(salesReportProvider);
    final dateRange = ref.read(dateRangeForPeriodProvider);
    final filters = ref.read(reportFiltersProvider);

    reportAsync.whenData((report) {
      showModalBottomSheet(
        context: context,
        builder: (context) =>
            _ExportMenu(report: report, period: dateRange, filters: filters),
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodOptions = [
      PeriodFilter.today,

      PeriodFilter.yesterday,

      PeriodFilter.last7Days,

      PeriodFilter.last30Days,

      PeriodFilter.thisWeek,

      PeriodFilter.thisMonth,

      PeriodFilter.thisQuarter,

      PeriodFilter.thisYear,

      PeriodFilter.custom,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          'Sales Reports',

          style: JuselTextStyles.headlineLarge(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Export Report',
              onPressed: () => _showExportMenu(context, ref),
              color: JuselColors.primaryColor(context),
            ),
            const SizedBox(width: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton<PeriodFilter>(
                value: periodFilterState.filter,

                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: JuselColors.primaryColor(context),
                ),

                items: periodOptions
                    .map(
                      (filter) => DropdownMenuItem(
                        value: filter,

                        child: Text(
                          _getPeriodDisplayName(filter),

                          style: JuselTextStyles.bodyMedium(context).copyWith(
                            color: JuselColors.primaryColor(context),

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),

                onChanged: (filter) async {
                  if (filter != null) {
                    if (filter == PeriodFilter.custom) {
                      // Show date range picker

                      final range = await showDateRangePicker(
                        context: context,

                        firstDate: DateTime(2020),

                        lastDate: DateTime.now(),

                        initialDateRange: periodFilterState.customRange,

                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: JuselColors.primaryColor(context),
                              ),
                            ),

                            child: child!,
                          );
                        },
                      );

                      if (range != null) {
                        onCustomRangeSelected(range);
                      }
                    } else {
                      onPeriodChanged(filter);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getPeriodDisplayName(PeriodFilter filter) {
    switch (filter) {
      case PeriodFilter.today:
        return 'Today';

      case PeriodFilter.yesterday:
        return 'Yesterday';

      case PeriodFilter.last7Days:
        return 'Last 7 Days';

      case PeriodFilter.last30Days:
        return 'Last 30 Days';

      case PeriodFilter.thisWeek:
        return 'This Week';

      case PeriodFilter.thisMonth:
        return 'This Month';

      case PeriodFilter.thisQuarter:
        return 'This Quarter';

      case PeriodFilter.thisYear:
        return 'This Year';

      case PeriodFilter.custom:
        if (periodFilterState.filter == PeriodFilter.custom &&
            periodFilterState.customRange != null) {
          final start = periodFilterState.customRange!.start;

          final end = periodFilterState.customRange!.end;

          return '${_formatDate(start)} - ${_formatDate(end)}';
        }

        return 'Custom Range';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Dimension filters widget (product, category, payment method, user)
class _DimensionFilters extends ConsumerWidget {
  const _DimensionFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);

    // Use cached providers for products and users
    final products = ref.watch(_productsForFiltersProvider);
    final users = ref.watch(_usersForFiltersProvider);

    return Consumer(
      builder: (context, ref, child) {
        // Extract unique categories from products
        final categories =
            products.value?.map((p) => p.category).toSet().toList() ?? [];
        categories.sort();

        return Container(
          padding: const EdgeInsets.all(JuselSpacing.s16),
          decoration: BoxDecoration(
            color: JuselColors.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JuselColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: JuselTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (filters.hasFilters)
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(reportFiltersProvider.notifier).clearAll(),
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: JuselColors.destructiveColor(context),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s16),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'Product',
                      value: () {
                        if (filters.productId == null ||
                            products.value == null) {
                          return null;
                        }
                        try {
                          return products.value!
                              .firstWhere((p) => p.id == filters.productId)
                              .name;
                        } catch (_) {
                          return null;
                        }
                      }(),
                      onTap: () {
                        if (products.value != null &&
                            products.value!.isNotEmpty) {
                          _showProductPicker(context, ref, products.value!);
                        }
                      },
                      onClear: filters.productId != null
                          ? () => ref
                                .read(reportFiltersProvider.notifier)
                                .clearProduct()
                          : null,
                    ),
                    const SizedBox(width: 12),
                    _FilterChip(
                      label: 'Category',
                      value: filters.category,
                      onTap: () {
                        if (categories.isNotEmpty) {
                          _showCategoryPicker(context, ref, categories);
                        }
                      },
                      onClear: filters.category != null
                          ? () => ref
                                .read(reportFiltersProvider.notifier)
                                .clearCategory()
                          : null,
                    ),
                    const SizedBox(width: 12),
                    _FilterChip(
                      label: 'Payment',
                      value: filters.paymentMethod != null
                          ? _paymentLabel(filters.paymentMethod!)
                          : null,
                      onTap: () => _showPaymentMethodPicker(context, ref),
                      onClear: filters.paymentMethod != null
                          ? () => ref
                                .read(reportFiltersProvider.notifier)
                                .clearPaymentMethod()
                          : null,
                    ),
                    const SizedBox(width: 12),
                    _FilterChip(
                      label: 'Staff',
                      value: () {
                        if (filters.userId == null || users.value == null) {
                          return null;
                        }
                        try {
                          return users.value!
                              .firstWhere((u) => u.id == filters.userId)
                              .name;
                        } catch (_) {
                          return null;
                        }
                      }(),
                      onTap: () {
                        if (users.value != null && users.value!.isNotEmpty) {
                          _showUserPicker(context, ref, users.value!);
                        }
                      },
                      onClear: filters.userId != null
                          ? () => ref
                                .read(reportFiltersProvider.notifier)
                                .clearUser()
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProductPicker(
    BuildContext context,
    WidgetRef ref,
    List<ProductsTableData> products,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Product',
              style: JuselTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(product.category),
                    onTap: () {
                      ref
                          .read(reportFiltersProvider.notifier)
                          .setProduct(product.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(
    BuildContext context,
    WidgetRef ref,
    List<String> categories,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: JuselTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category),
                    onTap: () {
                      ref
                          .read(reportFiltersProvider.notifier)
                          .setCategory(category);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodPicker(BuildContext context, WidgetRef ref) {
    final options = [
      ('cash', 'Cash'),
      ('mobile_money', 'Mobile Money'),
      ('card', 'Card'),
      ('transfer', 'Bank Transfer'),
      ('pos', 'POS'),
      ('other', 'Other'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Payment Method',
              style: JuselTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map(
              (option) => ListTile(
                title: Text(option.$2),
                onTap: () {
                  ref
                      .read(reportFiltersProvider.notifier)
                      .setPaymentMethod(option.$1);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserPicker(
    BuildContext context,
    WidgetRef ref,
    List<UsersTableData> users,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Staff',
              style: JuselTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    onTap: () {
                      ref.read(reportFiltersProvider.notifier).setUser(user.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? JuselColors.primaryColor(context).withOpacity(0.1)
              : JuselColors.muted(context).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? JuselColors.primaryColor(context) : JuselColors.border(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: isSelected
                    ? JuselColors.primaryColor(context)
                    : JuselColors.mutedForeground(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 6),
              Text(
                ': $value',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.primaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (onClear != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    onClear?.call();
                  },
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: JuselColors.primaryColor(context),
                  ),
                ),
              ],
            ] else ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: JuselColors.mutedForeground(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Export menu bottom sheet
class _ExportMenu extends ConsumerStatefulWidget {
  final SalesReport report;
  final DateTimeRange period;
  final ReportFilters filters;

  const _ExportMenu({
    required this.report,
    required this.period,
    required this.filters,
  });

  @override
  ConsumerState<_ExportMenu> createState() => _ExportMenuState();
}

class _ExportMenuState extends ConsumerState<_ExportMenu> {
  bool _exporting = false;
  String? _exportError;

  Future<void> _exportCSV() async {
    setState(() {
      _exporting = true;
      _exportError = null;
    });

    try {
      final exportService = ReportsExportService();
      await exportService.exportAndShareCSV(
        report: widget.report,
        period: widget.period,
      );
      if (!mounted) return;

      Navigator.pop(context);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report exported and shared successfully'),
          backgroundColor: JuselColors.successColor(context),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _exportError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  Future<void> _exportPDF() async {
    setState(() {
      _exporting = true;
      _exportError = null;
    });

    try {
      // Get filter labels
      final db = ref.read(appDatabaseProvider);
      String? productName;
      String? userName;

      if (widget.filters.productId != null) {
        final product = await db.productsDao.getProduct(
          widget.filters.productId!,
        );
        productName = product?.name;
      }

      if (widget.filters.userId != null) {
        final user = await db.usersDao.getUserById(widget.filters.userId!);
        userName = user?.name;
      }

      final exportService = ReportsExportService();
      await exportService.exportAndSharePDF(
        report: widget.report,
        period: widget.period,
        productFilter: productName,
        categoryFilter: widget.filters.category,
        paymentMethodFilter: widget.filters.paymentMethod,
        userFilter: userName,
      );
      if (!mounted) return;

      Navigator.pop(context);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report exported and shared successfully'),
          backgroundColor: JuselColors.successColor(context),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _exportError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: JuselColors.muted(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Export Report',
            style: JuselTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          if (_exportError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: JuselColors.destructiveColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: JuselColors.destructiveColor(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: JuselColors.destructiveColor(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _exportError!,
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.destructiveColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ListTile(
            leading: Icon(
              Icons.description,
              color: JuselColors.primaryColor(context),
            ),
            title: Text(
              'Export as CSV',
              style: JuselTextStyles.bodyMedium(context),
            ),
            subtitle: Text(
              'Comma-separated values file',
              style: JuselTextStyles.bodySmall(context),
            ),
            onTap: _exporting ? null : _exportCSV,
            trailing: _exporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.chevron_right, color: JuselColors.mutedForeground(context)),
          ),
          ListTile(
            leading: Icon(
              Icons.picture_as_pdf,
              color: JuselColors.primaryColor(context),
            ),
            title: Text(
              'Export as PDF',
              style: JuselTextStyles.bodyMedium(context),
            ),
            subtitle: Text(
              'Portable document format',
              style: JuselTextStyles.bodySmall(context),
            ),
            onTap: _exporting ? null : _exportPDF,
            trailing: _exporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.chevron_right, color: JuselColors.mutedForeground(context)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final SalesReport report;

  const _SummaryCards({required this.report});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 540;
        final crossAxisCount = 2;
        final aspect = isCompact ? 1.38 : 1.6;
        final spacing = isCompact ? 10.0 : 12.0;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: aspect,
          ),
          itemBuilder: (_, index) {
            switch (index) {
              case 0:
                return _SummaryCard(
                  title: 'Sales',
                  value: _formatCurrency(report.totalSales),
                  icon: Icons.attach_money,
                  iconColor: JuselColors.primaryColor(context),
                );
              case 1:
                return _SummaryCard(
                  title: 'Profit',
                  value: _formatCurrency(report.totalProfit),
                  icon: Icons.trending_up,
                  iconColor: JuselColors.primaryColor(context),
                  valueColor: JuselColors.primaryColor(context),
                );
              case 2:
                return _SummaryCard(
                  title: 'Transactions',
                  value: report.totalTransactions.toString(),
                  icon: Icons.receipt_long,
                  iconColor: JuselColors.successColor(context),
                );
              case 3:
                return _SummaryCard(
                  title: 'Profit Margin',
                  value: '${report.profitMargin.toStringAsFixed(1)}%',
                  icon: Icons.percent,
                  iconColor: JuselColors.warningColor(context),
                );
              default:
                return const SizedBox();
            }
          },
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    return 'GHS ${amount.toStringAsFixed(2)}';
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: JuselColors.border(context).withValues(alpha: 0.9),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  color: JuselColors.foreground(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Icon(
                icon,
                size: 27,
                color: iconColor,
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s12),
          Text(
            value,
            style: JuselTextStyles.headlineLarge(context).copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? JuselColors.foreground(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodBreakdown extends StatelessWidget {
  final SalesReport report;

  final void Function(String method, double amount) onMethodTap;

  const _PaymentMethodBreakdown({
    required this.report,

    required this.onMethodTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = report.totalSales;

    final entries =
        report.salesByPaymentMethod.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (total == 0 || entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: JuselColors.card(context),

          borderRadius: BorderRadius.circular(12),

          border: Border.all(color: JuselColors.border(context)),
        ),

        child: Center(
          child: Text(
            'No payment data available',

            style: JuselTextStyles.bodyMedium(context).copyWith(
              color: JuselColors.mutedForeground(context),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method Breakdown',
          style: JuselTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: JuselSpacing.s12),
        Container(
          padding: const EdgeInsets.all(JuselSpacing.s20),
          decoration: BoxDecoration(
            color: JuselColors.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JuselColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ...entries.asMap().entries.map((entry) {
                final method = entry.value.key;
                final amount = entry.value.value;
                final percentage = (amount / total) * 100;
                final color = _paymentColor(context, method, entry.key);
                final isLast = entry.key == entries.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: () => onMethodTap(method, amount),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s12),
                        child: _PaymentMethodItem(
                          method: _paymentLabel(method),
                          amount: amount,
                          percentage: percentage,
                          color: color,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: JuselColors.border(context),
                        thickness: 1,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodItem extends StatelessWidget {
  final String method;

  final double amount;

  final double percentage;

  final Color color;

  const _PaymentMethodItem({
    required this.method,

    required this.amount,

    required this.percentage,

    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(
              method,

              style: JuselTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              'GHS ${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',

              style: JuselTextStyles.bodyMedium(context).copyWith(
                color: JuselColors.mutedForeground(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(4),

          child: LinearProgressIndicator(
            value: percentage / 100,

            backgroundColor: JuselColors.muted(context),

            valueColor: AlwaysStoppedAnimation<Color>(color),

            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _TopProductsTable extends StatelessWidget {
  final SalesReport report;

  final void Function(ProductSalesMetric) onProductTap;

  const _TopProductsTable({required this.report, required this.onProductTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Products by Sales',
          style: JuselTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: JuselSpacing.s12),
        Container(
          decoration: BoxDecoration(
            color: JuselColors.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JuselColors.border(context)),
          ),
          child: report.topProducts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No product sales data available',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                  ),
                )
              : Column(
                  children: report.topProducts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    final isLast = index == report.topProducts.length - 1;

                    return Column(
                      children: [
                        InkWell(
                          onTap: () => onProductTap(product),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: JuselSpacing.s20,
                              vertical: JuselSpacing.s16,
                            ),
                            child: _ProductRow(rank: index + 1, product: product),
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            color: JuselColors.border(context),
                            thickness: 1,
                          ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  final int rank;

  final ProductSalesMetric product;

  const _ProductRow({required this.rank, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: rank <= 3
                ? JuselColors.primaryColor(context).withOpacity(0.1)
                : JuselColors.muted(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: JuselTextStyles.bodySmall(context).copyWith(
                fontWeight: FontWeight.w700,
                color: rank <= 3
                    ? JuselColors.primaryColor(context)
                    : JuselColors.mutedForeground(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.productName,
                style: JuselTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${product.quantitySold} sold',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'GHS ${product.revenue.toStringAsFixed(2)}',
              style: JuselTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w700,
                color: JuselColors.primaryColor(context),
              ),
            ),
            Text(
              '${product.profitMargin.toStringAsFixed(1)}% margin',
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DailyBreakdownChart extends StatelessWidget {
  final SalesReport report;

  final void Function(DailySalesMetric) onDayTap;

  const _DailyBreakdownChart({required this.report, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Sales Breakdown',
          style: JuselTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: JuselSpacing.s12),
        Container(
          padding: const EdgeInsets.all(JuselSpacing.s20),
          decoration: BoxDecoration(
            color: JuselColors.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JuselColors.border(context)),
          ),
          child: report.dailyBreakdown.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No daily breakdown data available',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (report.dailyBreakdown.isNotEmpty) ...[
                      SizedBox(
                        height: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: report.dailyBreakdown.map((daily) {
                            final maxSales = report.dailyBreakdown
                                .map((d) => d.sales)
                                .reduce((a, b) => a > b ? a : b);
                            final height = maxSales > 0 ? (daily.sales / maxSales) : 0.0;

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Tooltip(
                                      message:
                                          'GHS ${daily.sales.toStringAsFixed(2)}\n${daily.transactions} transactions\nTap for details',
                                      child: InkWell(
                                        onTap: () => onDayTap(daily),
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          height: height * 180,
                                          decoration: BoxDecoration(
                                            color: JuselColors.primaryColor(context),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM d').format(daily.date),
                                      style: JuselTextStyles.bodySmall(context).copyWith(
                                        color: JuselColors.mutedForeground(context),
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ProductBreakdownList extends StatelessWidget {
  final SalesReport report;

  const _ProductBreakdownList({required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.productBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Products Breakdown',
          style: JuselTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: JuselSpacing.s12),
        Container(
          decoration: BoxDecoration(
            color: JuselColors.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JuselColors.border(context)),
          ),
          child: Column(
            children: report.productBreakdown.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              final isLast = index == report.productBreakdown.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: JuselSpacing.s20,
                      vertical: JuselSpacing.s16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName,
                                style: JuselTextStyles.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${product.quantitySold} sold',
                                style: JuselTextStyles.bodySmall(context).copyWith(
                                  color: JuselColors.mutedForeground(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'GHS ${product.revenue.toStringAsFixed(2)}',
                              style: JuselTextStyles.bodyMedium(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Profit: GHS ${product.profit.toStringAsFixed(2)}',
                              style: JuselTextStyles.bodySmall(context).copyWith(
                                color: JuselColors.mutedForeground(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: JuselColors.border(context),
                      thickness: 1,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Category Contribution Section
class _CategoryContributionSection extends ConsumerWidget {
  const _CategoryContributionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryDataAsync = ref.watch(categoryContributionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Contribution',
          style: JuselTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: JuselSpacing.s12),
        categoryDataAsync.when(
          loading: () => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: JuselColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: JuselColors.border(context)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: JuselColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: JuselColors.border(context)),
            ),
            child: Center(
              child: Text(
                'Error loading category data: $error',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.destructiveColor(context),
                ),
              ),
            ),
          ),
          data: (categoryData) {
            if (categoryData.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: JuselColors.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: JuselColors.border(context)),
                ),
                child: Center(
                  child: Text(
                    'No category data available',
                    style: JuselTextStyles.bodyMedium(context).copyWith(
                      color: JuselColors.mutedForeground(context),
                    ),
                  ),
                ),
              );
            }

            final totalRevenue = categoryData.values
                .map((m) => m.revenue)
                .fold(0.0, (a, b) => a + b);

            final sortedCategories = categoryData.values.toList()
              ..sort((a, b) => b.revenue.compareTo(a.revenue));

            return Container(
              decoration: BoxDecoration(
                color: JuselColors.card(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: JuselColors.border(context)),
              ),
              child: Column(
                children: sortedCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final isLast = index == sortedCategories.length - 1;
                  final percentage = totalRevenue > 0
                      ? (category.revenue / totalRevenue) * 100
                      : 0.0;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: JuselSpacing.s20,
                          vertical: JuselSpacing.s16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    category.category,
                                    style: JuselTextStyles.bodyLarge(context).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  'GHS ${category.revenue.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                                  style: JuselTextStyles.bodyMedium(context).copyWith(
                                    color: JuselColors.mutedForeground(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: JuselColors.muted(context),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  JuselColors.primaryColor(context),
                                ),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${category.quantitySold} units • ${category.transactionCount} transactions',
                                  style: JuselTextStyles.bodySmall(context).copyWith(
                                    color: JuselColors.mutedForeground(context),
                                  ),
                                ),
                                Text(
                                  'Margin: ${category.profitMargin.toStringAsFixed(1)}%',
                                  style: JuselTextStyles.bodySmall(context).copyWith(
                                    color: JuselColors.successColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: JuselColors.border(context),
                          thickness: 1,
                        ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Payment Method Trends Section
class _PaymentMethodTrendsSection extends ConsumerWidget {
  const _PaymentMethodTrendsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(paymentMethodTrendsProvider);

    return trendsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: JuselColors.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: JuselColors.border(context)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: JuselColors.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: JuselColors.border(context)),
        ),
        child: Center(
          child: Text(
            'Error loading payment trends: $error',
            style: JuselTextStyles.bodySmall(context).copyWith(
              color: JuselColors.destructiveColor(context),
            ),
          ),
        ),
      ),
      data: (trends) {
        if (trends.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: JuselColors.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: JuselColors.border(context)),
            ),
            child: Center(
              child: Text(
                'No payment trend data available',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                ),
              ),
            ),
          );
        }

        // Get all unique payment methods
        final paymentMethods = <String>{};
        for (final dayData in trends.values) {
          paymentMethods.addAll(dayData.keys);
        }
        final sortedMethods = paymentMethods.toList()..sort();

        // Sort dates
        final sortedDates = trends.keys.toList()..sort();

        // Calculate totals per method
        final methodTotals = <String, double>{};
        for (final method in sortedMethods) {
          methodTotals[method] = 0.0;
          for (final date in sortedDates) {
            methodTotals[method] =
                (methodTotals[method] ?? 0) + (trends[date]?[method] ?? 0);
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: JuselColors.card(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: JuselColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Method Trends',
                style: JuselTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              // Summary totals
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: sortedMethods.map((method) {
                  final total = methodTotals[method] ?? 0.0;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: JuselColors.muted(context).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: JuselColors.border(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _paymentLabel(method),
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GHS ${total.toStringAsFixed(2)}',
                          style: JuselTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: JuselColors.primaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Simple trend visualization
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final dayData = trends[date] ?? {};
                    final maxValue = methodTotals.values.reduce(
                      (a, b) => a > b ? a : b,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 40,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: sortedMethods.map((method) {
                                final value = dayData[method] ?? 0.0;
                                final height = maxValue > 0
                                    ? (value / maxValue) * 160
                                    : 0.0;
                                final color = _getPaymentMethodColor(context, method);
                                return Container(
                                  height: height,
                                  width: 40 / sortedMethods.length,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(2),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d').format(date),
                            style: JuselTextStyles.bodySmall(context).copyWith(
                              color: JuselColors.mutedForeground(context),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPaymentMethodColor(BuildContext context, String method) {
    switch (method) {
      case 'cash':
        return JuselColors.primaryColor(context);
      case 'mobile_money':
        return JuselColors.successColor(context);
      case 'card':
        return JuselColors.accentColor(context);
      default:
        return JuselColors.warningColor(context);
    }
  }
}

// ============================================================================

// DRILL-DOWN BOTTOM SHEETS

// ============================================================================

/// Bottom sheet showing product sales details

class _ProductDetailsSheet extends ConsumerWidget {
  final ProductSalesMetric product;

  const _ProductDetailsSheet({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.read(dateRangeForPeriodProvider);

    // Fetch sales for this product in the period

    final salesAsync =
        FutureProvider.autoDispose<List<StockMovementsTableData>>((ref) async {
          final db = ref.read(appDatabaseProvider);

          return db.stockMovementsDao.getSalesByDateRange(
            startDate: dateRange.start,

            endDate: dateRange.end,

            productId: product.productId,
          );
        });

    return DraggableScrollableSheet(
      initialChildSize: 0.7,

      minChildSize: 0.5,

      maxChildSize: 0.95,

      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: JuselColors.card(context),

          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),

        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),

              width: 40,

              height: 4,

              decoration: BoxDecoration(
                color: JuselColors.muted(context),

                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          product.productName,

                          style: JuselTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Sales Details',

                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close),

                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Row(
                children: [
                  Expanded(
                    child: _MetricItem(
                      label: 'Revenue',

                      value: 'GHS ${product.revenue.toStringAsFixed(2)}',

                      color: JuselColors.primaryColor(context),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _MetricItem(
                      label: 'Profit',

                      value: 'GHS ${product.profit.toStringAsFixed(2)}',

                      color: JuselColors.successColor(context),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _MetricItem(
                      label: 'Sold',

                      value: '${product.quantitySold}',

                      color: JuselColors.warningColor(context),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final sales = ref.watch(salesAsync);

                  return sales.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (e, _) => Center(
                      child: Text(
                        'Error loading sales: $e',

                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.destructiveColor(context),
                        ),
                      ),
                    ),

                    data: (salesList) {
                      if (salesList.isEmpty) {
                        return Center(
                          child: Text(
                            'No sales found for this period',

                            style: JuselTextStyles.bodyMedium(context).copyWith(
                              color: JuselColors.mutedForeground(context),
                            ),
                          ),
                        );
                      }

                      // Pagination: show first 50 items
                      const pageSize = 50;
                      final totalItems = salesList.length;
                      final itemsToShow = totalItems > pageSize
                          ? pageSize
                          : totalItems;

                      return ListView.builder(
                        controller: scrollController,

                        padding: const EdgeInsets.all(20),

                        itemCount:
                            itemsToShow + (totalItems > pageSize ? 1 : 0),

                        itemBuilder: (context, index) {
                          if (index == itemsToShow && totalItems > pageSize) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Showing $itemsToShow of $totalItems items',
                                  style: JuselTextStyles.bodySmall(context).copyWith(
                                    color: JuselColors.mutedForeground(context),
                                  ),
                                ),
                              ),
                            );
                          }

                          final sale = salesList[index];

                          return _SaleListItem(sale: sale);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet showing daily sales details

class _DayDetailsSheet extends ConsumerWidget {
  final DailySalesMetric daily;

  const _DayDetailsSheet({required this.daily});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,

      minChildSize: 0.5,

      maxChildSize: 0.95,

      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: JuselColors.card(context),

          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),

        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),

              width: 40,

              height: 4,

              decoration: BoxDecoration(
                color: JuselColors.muted(context),

                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(daily.date),

                          style: JuselTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '${daily.transactions} transactions',

                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close),

                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Row(
                children: [
                  Expanded(
                    child: _MetricItem(
                      label: 'Sales',

                      value: 'GHS ${daily.sales.toStringAsFixed(2)}',

                      color: JuselColors.primaryColor(context),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _MetricItem(
                      label: 'Profit',

                      value: 'GHS ${daily.profit.toStringAsFixed(2)}',

                      color: JuselColors.successColor(context),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _MetricItem(
                      label: 'Transactions',

                      value: '${daily.transactions}',

                      color: JuselColors.warningColor(context),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final sales = ref.watch(_salesForDayProvider(daily.date));

                  return sales.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (e, _) => Center(
                      child: Text(
                        'Error loading sales: $e',

                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.destructiveColor(context),
                        ),
                      ),
                    ),

                    data: (salesList) {
                      if (salesList.isEmpty) {
                        return Center(
                          child: Text(
                            'No sales found for this day',

                            style: JuselTextStyles.bodyMedium(context).copyWith(
                              color: JuselColors.mutedForeground(context),
                            ),
                          ),
                        );
                      }

                      // Pagination: show first 50 items
                      const pageSize = 50;
                      final totalItems = salesList.length;
                      final itemsToShow = totalItems > pageSize
                          ? pageSize
                          : totalItems;

                      return ListView.builder(
                        controller: scrollController,

                        padding: const EdgeInsets.all(20),

                        itemCount:
                            itemsToShow + (totalItems > pageSize ? 1 : 0),

                        itemBuilder: (context, index) {
                          if (index == itemsToShow && totalItems > pageSize) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Showing $itemsToShow of $totalItems items',
                                  style: JuselTextStyles.bodySmall(context).copyWith(
                                    color: JuselColors.mutedForeground(context),
                                  ),
                                ),
                              ),
                            );
                          }

                          final sale = salesList[index];

                          return _SaleListItem(sale: sale);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet showing payment method transaction details

class _PaymentMethodDetailsSheet extends ConsumerWidget {
  final String method;

  final double amount;

  final DateTimeRange period;

  const _PaymentMethodDetailsSheet({
    required this.method,

    required this.amount,

    required this.period,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodName = _paymentLabel(method);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,

      minChildSize: 0.5,

      maxChildSize: 0.95,

      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: JuselColors.card(context),

          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),

        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),

              width: 40,

              height: 4,

              decoration: BoxDecoration(
                color: JuselColors.muted(context),

                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          '$methodName Transactions',

                          style: JuselTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'GHS ${amount.toStringAsFixed(2)} total',

                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close),

                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final sales = ref.watch(
                    _salesForPaymentProvider(
                      _PaymentSalesQuery(range: period, method: method),
                    ),
                  );

                  return sales.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (e, _) => Center(
                      child: Text(
                        'Error loading transactions: $e',

                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.destructiveColor(context),
                        ),
                      ),
                    ),

                    data: (salesList) {
                      if (salesList.isEmpty) {
                        return Center(
                          child: Text(
                            'No transactions found',

                            style: JuselTextStyles.bodyMedium(context).copyWith(
                              color: JuselColors.mutedForeground(context),
                            ),
                          ),
                        );
                      }

                      // Pagination: show first 50 items
                      const pageSize = 50;
                      final totalItems = salesList.length;
                      final itemsToShow = totalItems > pageSize
                          ? pageSize
                          : totalItems;

                      return ListView.builder(
                        controller: scrollController,

                        padding: const EdgeInsets.all(20),

                        itemCount:
                            itemsToShow + (totalItems > pageSize ? 1 : 0),

                        itemBuilder: (context, index) {
                          if (index == itemsToShow && totalItems > pageSize) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Showing $itemsToShow of $totalItems items',
                                  style: JuselTextStyles.bodySmall(context).copyWith(
                                    color: JuselColors.mutedForeground(context),
                                  ),
                                ),
                              ),
                            );
                          }

                          final sale = salesList[index];

                          return _SaleListItem(sale: sale);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Metric item widget for summary cards

class _MetricItem extends StatelessWidget {
  final String label;

  final String value;

  final Color color;

  const _MetricItem({
    required this.label,

    required this.value,

    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),

        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: color.withOpacity(0.3)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,

            style: JuselTextStyles.bodySmall(context).copyWith(
              color: JuselColors.mutedForeground(context),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,

            style: JuselTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w700,

              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sale list item widget

class _SaleListItem extends ConsumerWidget {
  final StockMovementsTableData sale;

  const _SaleListItem({required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(_productByIdProvider(sale.productId));

    final productName = product.value?.name ?? 'Unknown Product';

    final revenue =
        sale.totalRevenue ??
        (sale.sellingPricePerUnit != null
            ? sale.sellingPricePerUnit! * sale.quantityUnits.toDouble()
            : 0.0);

    final payment = sale.paymentMethod ?? 'cash';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: JuselColors.muted(context).withOpacity(0.3),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: JuselColors.border(context)),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  productName,

                  style: JuselTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Text(
                      '${sale.quantityUnits} units',

                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      '.',

                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      DateFormat('h:mm a').format(sale.createdAt),

                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                'GHS ${revenue.toStringAsFixed(2)}',

                style: JuselTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w700,

                  color: JuselColors.primaryColor(context),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 4),

                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),

                decoration: BoxDecoration(
                  color: _paymentColor(context, payment, 0).withOpacity(0.1),

                  borderRadius: BorderRadius.circular(4),
                ),

                child: Text(
                  _paymentLabel(payment),

                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: _paymentColor(context, payment, 0),

                    fontWeight: FontWeight.w600,

                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Price Overrides/Discounts Report Section
class _PriceOverridesSection extends ConsumerWidget {
  const _PriceOverridesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeForPeriodProvider);
    final overridesAsync = ref.watch(priceOverridesProvider(dateRange));

    return JuselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Overrides & Discounts',
            style: JuselTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          overridesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading overrides: ${error.toString()}',
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.destructiveColor(context),
                  ),
                ),
              ),
            ),
            data: (overrides) {
              if (overrides.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No price overrides in this period',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                  ),
                );
              }

              double totalDiscount = 0;
              for (final o in overrides) {
                totalDiscount += o.discountAmount;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: JuselColors.primaryColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Discounts',
                          style: JuselTextStyles.bodyMedium(context),
                        ),
                        Text(
                          'GHS ${totalDiscount.toStringAsFixed(2)}',
                          style: JuselTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: JuselColors.primaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...overrides
                      .take(10)
                      .map(
                        (override) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: JuselColors.background(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: JuselColors.border(context)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        override.productName,
                                        style: JuselTextStyles.bodyMedium(context)
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(override.date),
                                      style: JuselTextStyles.bodySmall(context).copyWith(
                                        color: JuselColors.mutedForeground(context),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Original: GHS ${override.originalPrice.toStringAsFixed(2)}',
                                      style: JuselTextStyles.bodySmall(context),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Override: GHS ${override.overridePrice.toStringAsFixed(2)}',
                                      style: JuselTextStyles.bodySmall(context).copyWith(
                                        color: JuselColors.destructiveColor(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (override.reason != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reason: ${override.reason}',
                                    style: JuselTextStyles.bodySmall(context).copyWith(
                                      color: JuselColors.mutedForeground(context),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Qty: ${override.quantity}',
                                      style: JuselTextStyles.bodySmall(context),
                                    ),
                                    Text(
                                      'Discount: GHS ${override.discountAmount.toStringAsFixed(2)}',
                                      style: JuselTextStyles.bodySmall(context).copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: JuselColors.destructiveColor(context),
                                      ),
                                    ),
                                    Text(
                                      'By: ${override.staffName}',
                                      style: JuselTextStyles.bodySmall(context).copyWith(
                                        color: JuselColors.mutedForeground(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  if (overrides.length > 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Showing 10 of ${overrides.length} overrides',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Stock Alerts (Low Stock/Stock-Out) Section
class _StockAlertsSection extends ConsumerWidget {
  const _StockAlertsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeForPeriodProvider);
    final alertsAsync = ref.watch(stockAlertsProvider(dateRange));

    return JuselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Alerts History',
            style: JuselTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          alertsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading alerts: ${error.toString()}',
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.destructiveColor(context),
                  ),
                ),
              ),
            ),
            data: (alerts) {
              if (alerts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No stock alerts in this period',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                  ),
                );
              }

              final stockOuts = alerts
                  .where((a) => a.alertType == 'stock_out')
                  .length;
              final lowStocks = alerts
                  .where((a) => a.alertType == 'low_stock')
                  .length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: JuselColors.destructiveColor(context).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$stockOuts',
                                style: JuselTextStyles.headlineMedium(context).copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: JuselColors.destructiveColor(context),
                                ),
                              ),
                              Text(
                                'Stock Outs',
                                style: JuselTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: JuselColors.warningColor(context).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$lowStocks',
                                style: JuselTextStyles.headlineMedium(context).copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: JuselColors.warningColor(context),
                                ),
                              ),
                              Text(
                                'Low Stock',
                                style: JuselTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...alerts
                      .take(10)
                      .map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: JuselColors.background(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: alert.alertType == 'stock_out'
                                    ? JuselColors.destructiveColor(context)
                                    : JuselColors.warningColor(context),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        alert.productName,
                                        style: JuselTextStyles.bodyMedium(context)
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: alert.alertType == 'stock_out'
                                            ? JuselColors.destructiveColor(context)
                                                  .withOpacity(0.1)
                                            : JuselColors.warningColor(context).withOpacity(
                                                0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        alert.alertType == 'stock_out'
                                            ? 'OUT OF STOCK'
                                            : 'LOW STOCK',
                                        style: JuselTextStyles.bodySmall(context)
                                            .copyWith(
                                              color:
                                                  alert.alertType == 'stock_out'
                                                  ? JuselColors.destructiveColor(context)
                                                  : JuselColors.warningColor(context),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Date: ${DateFormat('MMM dd, yyyy').format(alert.alertDate)}',
                                      style: JuselTextStyles.bodySmall(context),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Stock: ${alert.stockLevel} units',
                                      style: JuselTextStyles.bodySmall(context),
                                    ),
                                  ],
                                ),
                                if (alert.daysOutOfStock != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Out of stock for ${alert.daysOutOfStock} days',
                                    style: JuselTextStyles.bodySmall(context).copyWith(
                                      color: JuselColors.destructiveColor(context),
                                    ),
                                  ),
                                ],
                                if (alert.restockedDate != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Restocked: ${DateFormat('MMM dd, yyyy').format(alert.restockedDate!)} (${alert.restockedQuantity} units)',
                                    style: JuselTextStyles.bodySmall(context).copyWith(
                                      color: JuselColors.successColor(context),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                  if (alerts.length > 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Showing 10 of ${alerts.length} alerts',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Production Batch Efficiency Section
class _ProductionBatchEfficiencySection extends ConsumerWidget {
  const _ProductionBatchEfficiencySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeForPeriodProvider);
    final batchesAsync = ref.watch(
      productionBatchEfficiencyProvider(dateRange),
    );

    return JuselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Production Batch Efficiency',
            style: JuselTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          batchesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading batches: ${error.toString()}',
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.destructiveColor(context),
                  ),
                ),
              ),
            ),
            data: (batches) {
              if (batches.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No production batches in this period',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...batches
                      .take(10)
                      .map(
                        (batch) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: JuselColors.background(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: JuselColors.border(context)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        batch.productName,
                                        style: JuselTextStyles.bodyMedium(context)
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(batch.productionDate),
                                      style: JuselTextStyles.bodySmall(context).copyWith(
                                        color: JuselColors.mutedForeground(context),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quantity',
                                            style: JuselTextStyles.bodySmall(context)
                                                .copyWith(
                                                  color: JuselColors
                                                      .mutedForeground(context),
                                                ),
                                          ),
                                          Text(
                                            '${batch.quantityProduced} units',
                                            style: JuselTextStyles.bodyMedium(context)
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Unit Cost',
                                            style: JuselTextStyles.bodySmall(context)
                                                .copyWith(
                                                  color: JuselColors
                                                      .mutedForeground(context),
                                                ),
                                          ),
                                          Text(
                                            'GHS ${batch.unitCost.toStringAsFixed(2)}',
                                            style: JuselTextStyles.bodyMedium(context)
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total Cost',
                                            style: JuselTextStyles.bodySmall(context)
                                                .copyWith(
                                                  color: JuselColors
                                                      .mutedForeground(context),
                                                ),
                                          ),
                                          Text(
                                            'GHS ${batch.totalCost.toStringAsFixed(2)}',
                                            style: JuselTextStyles.bodyMedium(context)
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Selling Price',
                                            style: JuselTextStyles.bodySmall(context)
                                                .copyWith(
                                                  color: JuselColors
                                                      .mutedForeground(context),
                                                ),
                                          ),
                                          Text(
                                            'GHS ${batch.sellingPrice.toStringAsFixed(2)}',
                                            style: JuselTextStyles.bodyMedium(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (batch.profitMargin != null)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Profit Margin',
                                              style: JuselTextStyles.bodySmall(context)
                                                  .copyWith(
                                                    color: JuselColors
                                                        .mutedForeground(context),
                                                  ),
                                            ),
                                            Text(
                                              '${batch.profitMargin!.toStringAsFixed(1)}%',
                                              style: JuselTextStyles.bodyMedium(context)
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        batch.profitMargin! > 0
                                                        ? JuselColors.successColor(context)
                                                        : JuselColors
                                                              .destructive,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  if (batches.length > 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Showing 10 of ${batches.length} batches',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
