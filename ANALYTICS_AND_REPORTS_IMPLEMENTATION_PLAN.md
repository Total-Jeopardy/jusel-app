# Analytics & Reports Implementation Plan

## Overview
This plan outlines the implementation of comprehensive sales analytics, reporting, and payment method tracking to make the app production-ready for inventory and sales management.

---

## Current State Analysis

### ✅ What Exists
1. **Basic Dashboard Metrics**: Sales total, profit total, inventory value, production value
2. **Top Products**: Top 3 products by revenue (basic)
3. **Payment Method UI**: Dialog exists in `cart_view.dart` but value is hardcoded to 'Cash'
4. **Period Filter UI**: Dropdown exists but `onChanged: (_) {}` is empty (non-functional)
5. **Reports Tab**: Placeholder screen only

### ❌ What's Missing
1. **Payment Method Storage**: Not stored in database
2. **Date Filtering**: Dashboard filter doesn't actually filter data
3. **Reports Screen**: No analytics/reports functionality
4. **Period-based Analytics**: No daily/monthly/yearly breakdowns
5. **Payment Method Breakdown**: No analysis by payment type
6. **Product-level Analytics**: Limited to top 3, no detailed breakdowns
7. **Profit Analysis**: Basic calculation only, no period-based profit tracking
8. **Granular Breakdowns**: No drill-down capabilities

---

## Phase 1: Database Schema Updates

### 1.1 Add Payment Method to Stock Movements Table
**File**: `lib/core/database/tables/stock_movements_table.dart`

**Changes**:
```dart
// Add new column
TextColumn get paymentMethod => text().nullable()(); // 'cash' or 'mobile_money'
```

**Migration**:
- Bump schema version to 4
- Add migration in `app_database.dart` to add `paymentMethod` column
- Default existing records to 'cash' for backward compatibility

**Files to Update**:
- `lib/core/database/tables/stock_movements_table.dart`
- `lib/core/database/app_database.dart` (migration)
- Run `flutter pub run build_runner build --delete-conflicting-outputs`

---

## Phase 2: Payment Method Integration

### 2.1 Update Sales Service
**File**: `lib/core/services/sales_service.dart`

**Changes**:
- Add `paymentMethod` parameter to `sellProduct()` method
- Pass payment method to `recordSale()` in DAO

### 2.2 Update Stock Movements DAO
**File**: `lib/core/database/daos/stock_movements_dao.dart`

**Changes**:
- Add `paymentMethod` parameter to `recordSale()` method
- Store payment method in database insert

### 2.3 Update Cart View
**File**: `lib/features/sales/view/cart_view.dart`

**Changes**:
- Fix `_showPaymentMethodDialog()` to return selected method
- Pass selected payment method to `SalesCompletedScreen`
- Pass payment method to `salesService.sellProduct()` for each item

### 2.4 Update Sync Orchestrator
**File**: `lib/core/sync/sync_orchestrator.dart`

**Changes**:
- Include `paymentMethod` in sale sync payload

**Files to Update**:
- `lib/core/services/sales_service.dart`
- `lib/core/database/daos/stock_movements_dao.dart`
- `lib/features/sales/view/cart_view.dart`
- `lib/core/sync/sync_orchestrator.dart`

---

## Phase 3: Dashboard Date Filtering

### 3.1 Create Period Filter Provider
**File**: `lib/features/dashboard/providers/period_filter_provider.dart` (NEW)

**Purpose**: Manage selected period filter state

**Implementation**:
```dart
enum PeriodFilter {
  today,
  thisWeek,
  thisMonth,
  thisQuarter,
  thisYear,
  custom,
}

class PeriodFilterNotifier extends StateNotifier<PeriodFilter> {
  PeriodFilterNotifier() : super(PeriodFilter.today);
  
  void setFilter(PeriodFilter filter) {
    state = filter;
  }
  
  DateTimeRange getDateRange() {
    final now = DateTime.now();
    switch (state) {
      case PeriodFilter.today:
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: start, end: now);
      case PeriodFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(start: start, end: now);
      // ... other cases
    }
  }
}

final periodFilterProvider = StateNotifierProvider<PeriodFilterNotifier, PeriodFilter>((ref) {
  return PeriodFilterNotifier();
});
```

### 3.2 Update Dashboard Provider
**File**: `lib/features/dashboard/providers/dashboard_provider.dart`

**Changes**:
- Accept `DateTimeRange` parameter
- Filter movements by `createdAt` within date range
- Update all calculations to use filtered data

**New Provider Signature**:
```dart
final dashboardProvider = FutureProvider.family<DashboardMetrics, DateTimeRange>((ref, dateRange) async {
  // Filter movements by dateRange
  final salesMovements = movements.where((m) => 
    m.createdAt.isAfter(dateRange.start) && 
    m.createdAt.isBefore(dateRange.end.add(Duration(days: 1)))
  ).toList();
  // ... rest of logic
});
```

### 3.3 Update Dashboard UI
**File**: `lib/features/dashboard/view/boss_dashboard.dart`

**Changes**:
- Watch `periodFilterProvider`
- Get date range from provider
- Pass date range to `dashboardProvider`
- Wire dropdown `onChanged` to update filter
- Update dropdown value to reflect selected filter

**Files to Update**:
- `lib/features/dashboard/providers/period_filter_provider.dart` (NEW)
- `lib/features/dashboard/providers/dashboard_provider.dart`
- `lib/features/dashboard/view/boss_dashboard.dart`

---

## Phase 4: Reports Screen Implementation

### 4.1 Create Reports Data Models
**File**: `lib/features/reports/models/report_models.dart` (NEW)

**Models**:
```dart
class SalesReport {
  final double totalSales;
  final double totalProfit;
  final int totalTransactions;
  final Map<String, double> salesByPaymentMethod; // 'cash': 1000, 'mobile_money': 500
  final List<ProductSalesMetric> topProducts;
  final List<DailySalesMetric> dailyBreakdown;
  final DateTimeRange period;
}

class ProductSalesMetric {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double profit;
  final double profitMargin; // percentage
}

class DailySalesMetric {
  final DateTime date;
  final double sales;
  final double profit;
  final int transactions;
}

class PaymentMethodBreakdown {
  final String method; // 'cash' or 'mobile_money'
  final double amount;
  final int transactionCount;
  final double percentage; // of total sales
}
```

### 4.2 Create Reports Service
**File**: `lib/core/services/reports_service.dart` (NEW)

**Purpose**: Business logic for generating reports

**Methods**:
```dart
class ReportsService {
  Future<SalesReport> generateSalesReport({
    required DateTimeRange period,
    String? productId, // optional filter by product
  });
  
  Future<List<ProductSalesMetric>> getTopProductsBySales({
    required DateTimeRange period,
    int limit = 10,
  });
  
  Future<List<ProductSalesMetric>> getTopProductsByProfit({
    required DateTimeRange period,
    int limit = 10,
  });
  
  Future<Map<String, double>> getSalesByPaymentMethod({
    required DateTimeRange period,
  });
  
  Future<List<DailySalesMetric>> getDailyBreakdown({
    required DateTimeRange period,
  });
  
  Future<List<ProductSalesMetric>> getProductBreakdown({
    required DateTimeRange period,
  });
}
```

### 4.3 Create Reports Providers
**File**: `lib/features/reports/providers/reports_provider.dart` (NEW)

**Providers**:
```dart
final reportsServiceProvider = Provider<ReportsService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReportsService(db);
});

final salesReportProvider = FutureProvider.family<SalesReport, DateTimeRange>((ref, period) async {
  final service = ref.watch(reportsServiceProvider);
  return await service.generateSalesReport(period: period);
});
```

### 4.4 Create Reports Screen
**File**: `lib/features/reports/view/reports_screen.dart` (NEW)

**Sections**:
1. **Period Selector**: Dropdown with Today/This Week/This Month/This Year/Custom
2. **Summary Cards**: Total Sales, Total Profit, Transactions, Profit Margin %
3. **Payment Method Breakdown**: Pie chart or bar chart showing cash vs mobile money
4. **Top Products Table**: Sortable by Sales/Profit/Quantity
5. **Daily Breakdown Chart**: Line/bar chart showing sales over time
6. **Product Breakdown**: Expandable list with drill-down to product details
7. **Export Options**: Share/Export report (future enhancement)

**UI Components**:
- `_PeriodSelector` widget
- `_SummaryCards` widget
- `_PaymentMethodBreakdown` widget (chart)
- `_TopProductsTable` widget
- `_DailyBreakdownChart` widget
- `_ProductBreakdownList` widget

### 4.5 Replace Reports Placeholder
**File**: `lib/features/dashboard/view/boss_dashboard.dart`

**Changes**:
- Replace `_ReportsPlaceholder` with `ReportsScreen()`

**Files to Create**:
- `lib/features/reports/models/report_models.dart`
- `lib/core/services/reports_service.dart`
- `lib/features/reports/providers/reports_provider.dart`
- `lib/features/reports/view/reports_screen.dart`

**Files to Update**:
- `lib/features/dashboard/view/boss_dashboard.dart`

---

## Phase 5: Enhanced Analytics Features

### 5.1 Product Detail Analytics
**File**: `lib/features/products/view/product_detail_screen.dart`

**Add Section**:
- Sales history chart for the product
- Profit margin over time
- Best selling periods
- Link to full product report

### 5.2 Sales History Enhancement
**File**: `lib/features/stock/view/stock_history_screen.dart`

**Enhancements**:
- Filter by payment method
- Group by date/product
- Show payment method in movement cards

### 5.3 Dashboard Enhancements
**File**: `lib/features/dashboard/view/boss_dashboard.dart`

**Add**:
- Payment method breakdown widget
- Quick links to reports
- Period comparison (vs previous period)

---

## Phase 6: UI/UX Polish

### 6.1 Charts Library
**Dependency**: Add `fl_chart` or `syncfusion_flutter_charts` to `pubspec.yaml`

**Usage**:
- Payment method pie chart
- Daily sales line chart
- Product comparison bar chart

### 6.2 Loading & Error States
- Skeleton loaders for reports
- Empty states with helpful messages
- Error retry mechanisms

### 6.3 Responsive Design
- Ensure reports work on different screen sizes
- Scrollable tables
- Collapsible sections

---

## Implementation Order

### Week 1: Foundation
1. ✅ Phase 1: Database schema updates (payment method)
2. ✅ Phase 2: Payment method integration
3. ✅ Phase 3: Dashboard date filtering

### Week 2: Core Reports
4. ✅ Phase 4: Reports screen implementation
   - Start with basic sales report
   - Add payment method breakdown
   - Add top products table

### Week 3: Enhanced Analytics
5. ✅ Phase 5: Enhanced analytics features
6. ✅ Phase 6: UI/UX polish

---

## Testing Checklist

### Payment Method
- [ ] Payment method is saved to database
- [ ] Payment method appears in sales completed screen
- [ ] Payment method syncs to Firebase
- [ ] Historical sales without payment method default to 'cash'

### Date Filtering
- [ ] Today filter shows only today's data
- [ ] This week filter shows correct week range
- [ ] This month filter shows correct month range
- [ ] This quarter filter shows correct quarter range
- [ ] Dashboard metrics update when filter changes
- [ ] Filter persists across app restarts (optional)

### Reports Screen
- [ ] Reports screen loads without errors
- [ ] Period selector works correctly
- [ ] Summary cards show accurate totals
- [ ] Payment method breakdown is accurate
- [ ] Top products table is sortable
- [ ] Daily breakdown chart displays correctly
- [ ] Product breakdown shows all products
- [ ] Empty states display when no data
- [ ] Loading states show during data fetch
- [ ] Error states show with retry option

### Analytics Accuracy
- [ ] Sales totals match sum of individual transactions
- [ ] Profit calculations are correct
- [ ] Payment method percentages add up to 100%
- [ ] Top products are correctly ranked
- [ ] Daily breakdown matches filtered period
- [ ] Product breakdown matches filtered period

---

## Database Migration Strategy

### Migration 4: Add Payment Method
```dart
if (from < 4) {
  await m.addColumn(stockMovementsTable, stockMovementsTable.paymentMethod);
  // Set default value for existing records
  await m.database.exec('UPDATE stock_movements SET payment_method = "cash" WHERE payment_method IS NULL');
}
```

### Testing Migrations
- Test upgrade from schema 3 to 4
- Verify existing data integrity
- Test new sales with payment method
- Verify backward compatibility

---

## Future Enhancements (Post-MVP)

1. **Custom Date Range Picker**: Allow users to select any date range
2. **Export Reports**: PDF/CSV export functionality
3. **Email Reports**: Scheduled email reports
4. **Comparative Analytics**: Compare periods (this month vs last month)
5. **Forecasting**: Predict future sales based on trends
6. **Multi-currency Support**: If expanding to other markets
7. **Advanced Filters**: Filter by product category, user, etc.
8. **Real-time Updates**: WebSocket integration for live dashboards
9. **Mobile Notifications**: Alert on sales milestones
10. **Inventory Analytics**: Stock turnover, reorder points, etc.

---

## Notes

- All date comparisons should use timezone-aware DateTime
- Consider timezone settings for accurate daily/monthly calculations
- Cache report data for performance (use `keepAlive` on providers)
- Consider pagination for large product breakdowns
- Add indexes on `createdAt` and `paymentMethod` columns for query performance
- Ensure all calculations handle null values gracefully
- Add unit tests for report calculations
- Consider using `compute()` for heavy calculations to avoid blocking UI

---

## File Structure

```
lib/
├── core/
│   ├── database/
│   │   ├── tables/
│   │   │   └── stock_movements_table.dart (UPDATE)
│   │   ├── daos/
│   │   │   └── stock_movements_dao.dart (UPDATE)
│   │   └── app_database.dart (UPDATE - migration)
│   ├── services/
│   │   ├── sales_service.dart (UPDATE)
│   │   └── reports_service.dart (NEW)
│   └── sync/
│       └── sync_orchestrator.dart (UPDATE)
├── features/
│   ├── dashboard/
│   │   ├── providers/
│   │   │   ├── dashboard_provider.dart (UPDATE)
│   │   │   └── period_filter_provider.dart (NEW)
│   │   └── view/
│   │       └── boss_dashboard.dart (UPDATE)
│   ├── reports/
│   │   ├── models/
│   │   │   └── report_models.dart (NEW)
│   │   ├── providers/
│   │   │   └── reports_provider.dart (NEW)
│   │   └── view/
│   │       └── reports_screen.dart (NEW)
│   └── sales/
│       └── view/
│           └── cart_view.dart (UPDATE)
└── pubspec.yaml (UPDATE - add chart library)
```

---

## Success Criteria

✅ Payment method is tracked and stored for all sales
✅ Dashboard date filter works correctly
✅ Reports screen displays comprehensive analytics
✅ All calculations are accurate and match source data
✅ UI is responsive and user-friendly
✅ Performance is acceptable (< 2s load time for reports)
✅ Empty states and error handling are implemented
✅ Code follows existing patterns and architecture

---

**End of Plan**


