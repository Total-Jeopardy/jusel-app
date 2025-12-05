# Jusel App – Project Status (Granular)
Last updated: 2024-12-19 (UX states audit completed)

## Overview
Deep, itemized view of what is done and what remains. Focus is on wiring real data, services, navigation, and sync. All references assume current main workspace (no hidden branches).

## Foundation (Done)
- Data layer: Drift schema + DAOs present (Products, StockMovements, ProductionBatches, PendingSyncQueue, Users, PriceHistory).
- Services in codebase: InventoryService, SalesService, RestockService, ProductionService, SyncOrchestrator, PriceOverrideService (not all wired to UI).
- Auth: AuthViewModel + repository; role on user used for boss gating.
- Taxonomy: `lib/core/utils/product_constants.dart` defines canonical categories/subcategories/status and helpers.
- Products create:
  - `lib/features/products/view/add_product_screen.dart`: consumer stateful form, validation, status toggle, produced detection helper, canonical mapping, local insert via `ProductsDao.createProduct`, enqueue `product_create` to sync queue, returns success to caller.
  - `lib/core/database/daos/products_dao.dart`: createProduct accepts `status`.
- Products list:
  - `lib/features/products/view/products_screen.dart`: loads `ProductsDao.getAllProducts()` + `InventoryService.getAllCurrentStock()`, status pills, search/filter (canonical aware), refresh after add.
- Lint: touched files pass `flutter analyze`.

## Remaining Work (Granular Checklist by Area)

### Products
- Product detail (`lib/features/products/view/product_detail_screen.dart`)
  - [x] Accept `productId` (replace mock ctor args).
  - [x] Replace mock data with DAO/service: fetch product via `ProductsDao.getProduct(id)`.
  - [x] Fetch stock via `InventoryService.getCurrentStock(id)`.
  - [x] Fetch movements summary via `StockMovementsDao.getMovementsForProduct(id)` for history cards.
  - [x] Replace static UI data bindings; handle loading/error/empty states (prefer Riverpod `AsyncValue` pattern).
  - [x] Ensure navigation back refreshes if edits occur elsewhere - **autoDispose provider handles auto-refresh**.

### Stock / Restock
- Stock detail (`lib/features/stock/view/stock_detail_screen.dart`)
  - [x] Add `productId` param; remove hardcoded name/category/stock.
  - [x] Replace mock data with DAO/service: load product + current stock (ProductsDao + InventoryService).
  - [x] Wire buttons:
    - [x] Restock Product -> `RestockScreen` with product context.
    - [x] Add to Purchase List -> placeholder SnackBar (service doesn't exist yet).
    - [x] View Production Batches -> `BatchScreen` filtered by productId.
    - [x] View All Movements -> `StockHistoryScreen` with productId.
    - [x] View Product Details -> `ProductDetailScreen` with productId.
  - [x] Recent activity: real movements (limit 5–10) from StockMovementsDao.
  - [x] Trend: compute last 7 days from movements for chart (custom painter chart with daily deltas, back-filled from current stock, empty state handled).
  - [x] Loading/error/empty states for each block.

- Restock (`lib/features/stock/view/restock_screen.dart`)
  - [x] Product context: accept `productId` and prefill product info; product picker modal for manual select (bottom sheet with active products, updates product info and stock context).
  - [x] Current user: get from `authViewModelProvider`.
  - [x] Call `RestockService.restockFromPacks` or `restockByUnits` based on input.
  - [x] Handle loading, validation, and error states (prefer Riverpod `AsyncValue`).
  - [x] Enqueue sync (service should already do; verify) - **verified: service enqueues**.
  - [x] Navigate to `RestockSuccessScreen` with actual restock result (product name, units added, new stock).

- Restock success (`lib/features/stock/view/restock_success_screen.dart`)
  - [x] Update "Back to Product" to go to `StockDetailScreen` or `ProductDetailScreen` with productId.
  - [x] Pass real restock context (stock delta, totals).

- Stock history (`lib/features/stock/view/stock_history_screen.dart`)
  - [x] Accept `productId`.
  - [x] Replace mock data with DAO/service: fetch movements via `StockMovementsDao.getMovementsForProduct(id)`.
  - [x] Real list rendering with dates/reasons/quantities; empty state.

### Production
- New batch (`lib/features/production/view/new_batch_screen.dart`)
  - [x] Wire "Save Batch" handler: gather form data, current user, call `ProductionService.createBatch`.
  - [x] Product picker (produced products only: `isProduced = true`; bottom sheet with selection, updates product context, disables save until selected).
  - [x] Validation, loading/error states, navigation to `BatchDetailScreen` with new batchId.

- Batch detail (`lib/features/stock/view/batch_detail_screen.dart`)
  - [x] Accept `batchId`.
  - [x] Fetch batch via `ProductionBatchesDao.getBatch(batchId)`.
  - [x] Fetch related product data + movements if referenced.
  - [x] Compute/display real cost breakdown.
  - [x] Wire "Related Movement" navigation (navigates to `StockHistoryScreen` with productId/name/currentStock; disabled when no movement exists).

- Batch list (`lib/features/production/view/batch_screen.dart`)
  - [x] Fetch batches (`ProductionBatchesDao.getBatchesForProduct(id)` or all).
  - [x] Filter sheet (date range/product/status) - date filtering implemented.
  - [x] Product picker - implemented with "All Products" option.
  - [x] Navigation uses real `batchId` to detail.

### Sales
- Sales screen (`lib/features/sales/view/sales_screen.dart`)
  - [x] Replace static products with DAO/service: active products from `ProductsDao` (status = active).
  - [x] Get stock per product from `InventoryService.getCurrentStock`.
  - [x] Optionally filter out zero-stock items - **out-of-stock items disabled but still visible**.
  - [x] Ensure add-to-cart respects stock availability (check InventoryService before adding).

- Sales completed (`lib/features/sales/view/sales_completed_screen.dart`)
  - [x] Wire Print (printing package) to generate/display receipt.
  - [x] Wire Share (share_plus) to share receipt text/PDF.
  - [x] Navigation: Start New Sale (clear cart, go sales), Back to Dashboard (router).

### Dashboards
- Boss dashboard (`lib/features/dashboard/view/boss_dashboard.dart`)
  - [x] Low stock list from `InventoryService.getLowStockProducts()`.
  - [x] Inventory metrics from `InventoryService.getTotalInventoryValue()` (via dashboardProvider).
  - [x] Sales/profit metrics from MetricsService (or equivalent) (via dashboardProvider).
  - [x] Navigation to stock detail with real productId.

- Apprentice dashboard (`lib/features/dashboard/view/apprentice_dashboard.dart`)
  - [x] Low stock from InventoryService.
  - [x] Navigation to stock detail with real productId.

### Account / Settings
- Pending items (`lib/features/account/view/pending_items_screen.dart`)
  - [x] Replace `_mockItems()` with `PendingSyncQueueDao.getAllPendingOperations()`.
  - [x] Parse operation types/payload; show timestamps/status.
  - [x] "Sync All Now": call `SyncOrchestrator.syncAll()`; show progress/error.

- Manage users (`lib/features/account/view/manage_users_screen.dart`)
  - [x] Fetch users from `UsersDao.getAllUsers()` (Riverpod FutureProvider with loading/error/empty states).
  - [x] Wire "View Activity" (placeholder SnackBar; full activity screen pending).
  - [x] Wire Activate/Deactivate (toggle with DB update, loading indicator, refresh on completion).
  - [x] "Add User": bottom sheet form creates user (Firebase Auth secondary instance + Firestore + local Drift, refreshes list).

- Auth flows
  - Reset password (`lib/features/auth/view/reset_password_screen.dart`):
    [x] Wire `_handleReset()` to `AuthRepository.resetUserPassword()`, add loading/success/error, navigate back.
  - Change password (`lib/features/auth/view/change_password_screen.dart`):
    [x] Wire handler to Firebase Auth `updatePassword` (+ reauth if needed).
  - Logout (`lib/features/account/view/account_screen.dart`):
    [x] Wire logout to `authViewModelProvider.notifier.signOut()`; navigate to login.

### Navigation Coherence
- [x] Ensure all routes pass IDs (productId, batchId) instead of mock objects - **verified: all routes use IDs**.
- [x] After mutations (add product, restock, batch creation), refresh parent screens or use Riverpod async providers for auto-refresh - **verified: ProductsScreen, BatchScreen, RestockScreen all refresh/invalidate appropriately**.

### Sync & IDs
- Sync contracts: align operationType + payloads with SyncOrchestrator:
  - [x] product_create: verified - matches _syncProductCreate with id, name, category, subcategory, isProduced, currentSellingPrice, currentCostPrice, unitsPerPack, status, createdAt, updatedAt.
- [x] restock: verified - matches _syncRestock with id, productId, quantity, costPerUnit, totalCost, createdByUserId, createdAt.
- [x] production: verified - matches _syncProduction with id, productId, quantityProduced, totalCost, unitCost, cost breakdown fields, notes, createdByUserId, createdAt.
- [x] sale: verified - matches _syncSale with id, productId, quantity, unitSellingPrice, unitCostPrice, totalRevenue, totalCost, profit, createdByUserId, createdAt.
- [x] price_change: verified - matches _syncPriceChange with expected pricing fields.
- [ ] product_update: supported by SyncOrchestrator but not currently enqueued (no update flow wired yet).
- ID strategy (decision): use locally generated timestamp string IDs (`DateTime.now().millisecondsSinceEpoch.toString()`) for products and all stock movements (sale/restock/production movement) to guarantee offline uniqueness; keep production batch IDs as local auto-increment ints and send them as strings in sync payloads. This aligns with SyncOrchestrator expectations, avoids extra UUID dependency, and ensures stable IDs for dedupe. No code changes needed—current services already follow this pattern.
- [x] Enqueue: verified - all services use exact operationType names SyncOrchestrator consumes; no mismatches found.
- [ ] Debug logging: in debug builds, log payloads before enqueue to catch shape drift vs SyncOrchestrator expectations (optional enhancement).

### UX States
- [x] Add consistent loading/error/empty states to all newly wired screens (detail/history/batch/sales/pending) - **verified: all screens have loading/error/empty states using Riverpod .when patterns with clear messaging**.
- [x] Validate numeric inputs across forms (restock, batch, sales overrides) - **completed: RestockScreen, NewBatchScreen, AddProductScreen now have numeric formatters and validation**.

## Testing Checklist
- Widget tests for wired screens: product detail, stock detail, restock, batch create/detail, sales, pending items (loading/error/empty + happy paths).
- Integration/e2e: add product → products refresh; restock → stock detail refresh; sales → stock decrement + dashboard metrics; batch creation → batch detail/list.
- Error-path coverage: failed service calls show user-friendly errors and preserve state.
- Data guards: add-to-cart respects current stock from InventoryService; restock validates inputs; batch save validates costs/quantities.
- Sync: unit tests around queue enqueue payload shapes (operationType and fields) for create/restock/production/sale/price_change.
- Offline/retry: simulate offline mode, queue ops, restart app, and verify sync resumes correctly.

## Quick Execution Order (suggested)
1) Stock flows: stock detail wiring + restock service + history (unblocks inventory accuracy).  
2) Production: new batch save + batch detail/list (cost accuracy).  
3) Sales: real data + completed actions (core revenue path).  
4) Dashboards: low stock/metrics wired.  
5) Account: pending items, manage users, auth flows (operational polish).  
6) Navigation cleanup and ID strategy confirmation.
