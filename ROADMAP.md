# Jusel App - Implementation Roadmap

## Overview
This roadmap outlines the remaining work to complete the app by wiring services, connecting to real data, and completing navigation flows.

---

## Screen → Data Source → Service Mapping Table

Quick reference for which DAO/Service to use for each screen:

| Screen | Primary Data Source | Service/DAO to Call | Secondary Data |
|--------|-------------------|-------------------|----------------|
| **ProductsScreen** | `ProductsDao.getAllProducts()` | `InventoryService.getAllCurrentStock()` | - |
| **ProductDetailScreen** | `ProductsDao.getProduct(id)` | `InventoryService.getCurrentStock(id)` | `StockMovementsDao.getMovementsForProduct(id)` |
| **StockDetailScreen** | `ProductsDao.getProduct(id)` | `InventoryService.getCurrentStock(id)` | `StockMovementsDao.getMovementsForProduct(id)` |
| **RestockScreen** | `ProductsDao.getProduct(id)` | `RestockService.restockFromPacks()` or `restockByUnits()` | - |
| **RestockSuccessScreen** | (Receives data from RestockScreen) | - | - |
| **StockHistoryScreen** | `StockMovementsDao.getMovementsForProduct(id)` | - | `ProductsDao.getProduct(id)` |
| **BatchScreen** | `ProductionBatchesDao.getBatchesForProduct(id)` | - | `ProductsDao.getProduct(id)` |
| **BatchDetailScreen** | `ProductionBatchesDao.getBatch(id)` | - | `ProductsDao.getProduct(batch.productId)`, `StockMovementsDao` |
| **NewBatchScreen** | `ProductsDao.getProductsByCategory()` (for picker) | `ProductionService.createProductionBatch()` | - |
| **SalesScreen** | `ProductsDao.getAllProducts()` (active only) | `SalesService.sellProduct()` | `InventoryService.getCurrentStock(id)` |
| **SalesCompletedScreen** | (Receives data from SalesScreen) | - | - |
| **PendingItemsScreen** | `PendingSyncQueueDao.getAllPendingItems()` | `SyncService.syncAllPending()` | - |
| **Dashboard (Boss/Apprentice)** | `InventoryService.getLowStockProducts()` | `InventoryService.getTotalInventoryValue()` | `ProductsDao.getAllProducts()` |
| **ManageUsersScreen** | `UsersDao.getAllUsers()` | `AuthRepository.resetUserPassword()` | - |
| **ResetPasswordScreen** | (Receives user data) | `AuthRepository.resetUserPassword()` | - |

**Key Services:**
- `InventoryService` - Stock calculations, low stock detection
- `RestockService` - Restock operations
- `ProductionService` - Batch creation
- `SalesService` - Sales operations
- `AuthRepository` - User management, password reset

**Key DAOs:**
- `ProductsDao` - Product CRUD
- `StockMovementsDao` - Stock movement records
- `ProductionBatchesDao` - Production batch records
- `UsersDao` - User records
- `PendingSyncQueueDao` - Sync queue operations

---

## Screen → Data Source → Service Mapping Table

Quick reference for implementation:

| Screen | Primary Data Source | Service/DAO to Call | Secondary Data |
|--------|-------------------|-------------------|----------------|
| **ProductsScreen** | `ProductsDao.getAllProducts()` | `InventoryService.getAllCurrentStock()` | - |
| **ProductDetailScreen** | `ProductsDao.getProduct(id)` | `InventoryService.getCurrentStock(id)` | `StockMovementsDao.getMovementsForProduct(id)` |
| **StockDetailScreen** | `ProductsDao.getProduct(id)` | `InventoryService.getCurrentStock(id)` | `StockMovementsDao.getMovementsForProduct(id)` |
| **RestockScreen** | `ProductsDao.getProduct(id)` | `RestockService.restockFromPacks()` or `restockByUnits()` | - |
| **RestockSuccessScreen** | (Receives data from RestockScreen) | - | - |
| **StockHistoryScreen** | `StockMovementsDao.getMovementsForProduct(id)` | - | `ProductsDao.getProduct(id)` |
| **BatchScreen** | `ProductionBatchesDao.getBatchesForProduct(id)` | - | `ProductsDao.getProduct(id)` |
| **BatchDetailScreen** | `ProductionBatchesDao.getBatch(id)` | - | `ProductsDao.getProduct(batch.productId)`, `StockMovementsDao` |
| **NewBatchScreen** | `ProductsDao.getProductsByCategory()` (for picker) | `ProductionService.createProductionBatch()` | - |
| **SalesScreen** | `ProductsDao.getAllProducts()` (active only) | `SalesService.sellProduct()` | `InventoryService.getCurrentStock(id)` |
| **SalesCompletedScreen** | (Receives data from SalesScreen) | - | - |
| **PendingItemsScreen** | `PendingSyncQueueDao.getAllPendingItems()` | `SyncService.syncAllPending()` | - |
| **Dashboard (Boss/Apprentice)** | `InventoryService.getLowStockProducts()` | `InventoryService.getTotalInventoryValue()` | `ProductsDao.getAllProducts()` |
| **ManageUsersScreen** | `UsersDao.getAllUsers()` | `AuthRepository.resetUserPassword()` | - |
| **ResetPasswordScreen** | (Receives user data) | `AuthRepository.resetUserPassword()` | - |

**Key Services:**
- `InventoryService` - Stock calculations, low stock detection
- `RestockService` - Restock operations
- `ProductionService` - Batch creation
- `SalesService` - Sales operations
- `AuthRepository` - User management, password reset

**Key DAOs:**
- `ProductsDao` - Product CRUD
- `StockMovementsDao` - Stock movement records
- `ProductionBatchesDao` - Production batch records
- `UsersDao` - User records
- `PendingSyncQueueDao` - Sync queue operations

---

## Phase 1: Critical Service Integrations (Week 1-2)
**Priority: HIGH** - Core functionality that users need immediately

**Test Strategy for Phase 1:**
- **Smoke tests:** Each wired action navigates correctly
- **Integration tests:** Service calls complete successfully
- **Error tests:** Invalid inputs show appropriate errors
- **Data tests:** Verify data persists after service calls
- **Manual E2E:** Complete flows from start to finish

### 1.1 Stock Detail Screen Actions
**Files:** `lib/features/stock/view/stock_detail_screen.dart`

- [ ] **Wire "Restock Product" button** (Line 55)
  - Navigate to `RestockScreen` with product context
  - Pass: `productId`, `productName`, `category`, `currentStock`
  - After restock, navigate back to Stock Detail with updated data

- [ ] **Wire "Add to Purchase List"** (Line 73)
  - Create `PurchaseListService` or extend existing service
  - Add product to purchase list table
  - Show success feedback

- [ ] **Wire "View Production Batches"** (Line 75)
  - Navigate to `BatchScreen` filtered by product
  - Pass: `productId`, `productName`

- [ ] **Wire "View All Movements"** (Line 76)
  - Navigate to `StockHistoryScreen` with product filter
  - Pass: `productId`, `productName`

- [ ] **Wire "View Product Details"** (Line 77)
  - Navigate to `ProductDetailScreen`
  - Pass: `productId` or `ProductsTableData`

### 1.2 Reset Password Service
**Files:** 
- `lib/features/auth/view/reset_password_screen.dart` (Line 160)
- Create: `lib/core/services/auth_service.dart` or extend `AuthRepository`

- [ ] Create `resetUserPassword()` method in `AuthRepository`
  - Use Firebase Admin SDK or Firebase Auth API
  - Update password for target user
  - Handle errors gracefully

- [ ] Wire `_handleReset()` in `ResetPasswordScreen`
  - Call service method
  - Show loading state
  - Show success/error feedback
  - Navigate back on success

### 1.3 Restock Service Integration
**Files:**
- `lib/features/stock/view/restock_screen.dart` (Line 180)
- `lib/core/services/restock_service.dart` (already exists)

- [ ] Wire restock flow in `RestockScreen`
  - Get current user ID from auth state
  - Call `RestockService.restockFromPacks()` or `restockByUnits()`
  - Handle loading/error states
  - Navigate to `RestockSuccessScreen` with real data
  - Pass: `productName`, `unitsAdded`, `newTotalStock`, etc.

- [ ] Update `RestockSuccessScreen` "Back to Product" button
  - Navigate to specific `ProductDetailScreen` or `StockDetailScreen`
  - Pass product context

### 1.4 Batch Creation Service
**Files:**
- `lib/features/production/view/new_batch_screen.dart` (Line 51)
- `lib/core/services/production_service.dart` (already exists)

- [ ] Wire "Save Batch" handler
  - Get current user ID
  - Collect all form data (ingredients, gas, labor, etc.)
  - Call `ProductionService.createProductionBatch()`
  - Navigate to `BatchDetailScreen` with new batch data
  - Handle validation errors

---

## Phase 2: Data Layer Integration (Week 2-3)
**Priority: HIGH** - Replace mock data with real database queries

**Test Strategy for Phase 2:**
- **Data accuracy:** Verify displayed data matches database
- **Loading states:** Test with slow network, verify loading indicators
- **Empty states:** Test with no data, verify appropriate messages
- **Real-time updates:** Change data in DB, verify UI reflects changes
- **Performance:** Test with large datasets (100+ products)
- **Offline:** Test data display when offline (should show cached data)

### 2.1 Products Screen - Real Data
**Files:** `lib/features/products/view/products_screen.dart`

- [ ] Replace hardcoded `_Product` list (Line 20-61)
  - Create `ProductsViewModel` using Riverpod
  - Fetch from `ProductsDao.getAllProducts()`
  - Use `InventoryService.getCurrentStock()` for stock counts
  - Calculate status (good/low/out) based on stock thresholds
  - Handle loading/error states

- [ ] Update `_ProductTile` to use real data
  - Convert `ProductsTableData` to display format
  - Use real stock calculations
  - Wire navigation with real product IDs

### 2.2 Stock Detail Screen - Real Data
**Files:** `lib/features/stock/view/stock_detail_screen.dart`

- [ ] Replace hardcoded product data
  - Accept `productId` parameter instead of individual fields
  - Fetch product from `ProductsDao.getProduct()`
  - Calculate current stock using `InventoryService.getCurrentStock()`
  - Fetch category from product data

- [ ] Replace mock "Recent Activity" (Line 332-337)
  - Query `StockMovementsDao.getMovementsForProduct()`
  - Format movements for display
  - Show last 5-10 movements

- [ ] Replace mock trend data
  - Query stock movements for last 7 days
  - Calculate daily stock levels
  - Draw real trend line

### 2.3 Batch Detail Screen - Real Data
**Files:** 
- `lib/features/stock/view/batch_detail_screen.dart`
- `lib/features/production/view/batch_screen.dart`

- [ ] Update `BatchDetailScreen` to accept `batchId`
  - Fetch batch from `ProductionBatchesDao`
  - Fetch related product data
  - Calculate real cost breakdown from batch data
  - Fetch related stock movement

- [ ] Update `BatchScreen` navigation
  - Pass real `batchId` instead of mock data
  - Fetch batches from `ProductionBatchesDao.getBatchesForProduct()`
  - Use real product data

### 2.4 Pending Items Screen - Real Data
**Files:** `lib/features/account/view/pending_items_screen.dart`

- [ ] Replace `_mockItems()` (Line 115)
  - Query `PendingSyncQueueDao.getAllPendingItems()`
  - Parse operation types and payloads
  - Format for display
  - Show real timestamps and status

- [ ] Wire "Sync All Now" button (Line 90)
  - Create `SyncService.syncAllPending()`
  - Process queue items
  - Update UI with sync progress
  - Handle errors and retries

### 2.5 Dashboard - Real Data
**Files:** 
- `lib/features/dashboard/view/boss_dashboard.dart`
- `lib/features/dashboard/view/apprentice_dashboard.dart`

- [ ] Replace hardcoded low stock alerts
  - Use `InventoryService.getLowStockProducts()`
  - Calculate real stock levels
  - Show actual product data

- [ ] Update navigation to Stock Detail
  - Pass real `productId` instead of hardcoded values
  - Fetch product data before navigation

### 2.6 Sales Screen - Real Data
**Files:** `lib/features/sales/view/sales_screen.dart`

- [ ] Replace static product list
  - Fetch active products from `ProductsDao`
  - Use real stock levels
  - Filter out out-of-stock items (optional)

---

## Phase 3: Navigation Improvements (Week 3)
**Priority: MEDIUM** - Better user experience

**Test Strategy for Phase 3:**
- **Navigation flow:** Test all navigation paths work correctly
- **Back navigation:** Verify back button returns to correct screen
- **Deep linking:** Test navigation with parameters
- **State preservation:** Verify data persists during navigation
- **Error navigation:** Test navigation after errors

### 3.1 Product Navigation Flow
- [ ] **Products Screen → Product Detail**
  - Pass `productId` to `ProductDetailScreen`
  - Fetch product data in detail screen

- [ ] **Product Detail → Stock Detail**
  - Add navigation option for low/out products
  - Share product context

- [ ] **Stock Detail → Product Detail**
  - Wire "View Product Details" link
  - Maintain navigation stack properly

### 3.2 Batch Navigation Flow
- [ ] **Batch Detail → Related Movement**
  - Wire "Related Movement" card (Line 303 in `batch_detail_screen.dart`)
  - Navigate to movement detail or stock history filtered by movement

- [ ] **Batch Detail → Edit Batch**
  - Create `EditBatchScreen` or reuse `NewBatchScreen` with edit mode
  - Pre-populate form with batch data
  - Update batch via `ProductionService`

### 3.3 Restock Navigation Flow
- [ ] **Restock Success → Product Detail**
  - Update "Back to Product" to navigate to specific product
  - Pass product context

### 3.4 Sales Completed Actions
**Files:** `lib/features/sales/view/sales_completed_screen.dart`

- [ ] **Wire Print button** (Line 84)
  - Use `printing` package or platform printing
  - Generate receipt PDF
  - Show print dialog

- [ ] **Wire Share button** (Line 106)
  - Use `share_plus` package
  - Share receipt as text or PDF
  - Include receipt details

- [ ] **Improve navigation**
  - "Start New Sale" → Navigate to Sales Screen (clear cart)
  - "Back to Dashboard" → Use router to go to dashboard route

---

## Phase 4: Additional Features (Week 4)
**Priority: LOW** - Nice to have

**Test Strategy for Phase 4:**
- **Feature-specific:** Test each new feature independently
- **Integration:** Verify new features work with existing flows
- **Edge cases:** Test boundary conditions for each feature

### 4.1 Manage Users Enhancements
**Files:** `lib/features/account/view/manage_users_screen.dart`

- [ ] **Wire "View Activity"** (Line 319)
  - Create `UserActivityScreen`
  - Show user's sales, restocks, batches
  - Query by `createdByUserId`

- [ ] **Wire Activate/Deactivate** (Line 322)
  - Create `UsersService.activateUser()` / `deactivateUser()`
  - Update user status in database
  - Refresh user list

- [ ] **Wire "Add User"** (Line 112)
  - Create `AddUserScreen`
  - Form for name, email, phone, role
  - Create user via Firebase Auth + Firestore

### 4.2 Batch Screen Enhancements
**Files:** `lib/features/production/view/batch_screen.dart`

- [ ] **Wire filter sheet** (Line 83)
  - Create filter bottom sheet
  - Filter by date range, product, status

- [ ] **Wire product picker** (Line 196)
  - Create product selection modal
  - Filter batches by selected product

### 4.3 Restock Screen Enhancements
**Files:** `lib/features/stock/view/restock_screen.dart`

- [ ] **Wire product selection** (Line 214)
  - Create product picker modal
  - Load products from database
  - Pre-fill form with product data

### 4.4 New Batch Screen Enhancements
**Files:** `lib/features/production/view/new_batch_screen.dart`

- [ ] **Wire product picker** (Line 195)
  - Create product selection modal
  - Filter to only produced products (`isProduced = true`)
  - Pre-fill product details

---

## Phase 5: Error Handling & Polish (Week 5)
**Priority: MEDIUM** - Production readiness

**Test Strategy for Phase 5:**
- **Error scenarios:** Test all error paths (network, validation, permissions)
- **User feedback:** Verify all errors show user-friendly messages
- **Recovery:** Test retry mechanisms work
- **Edge cases:** Test boundary conditions, null values, empty states
- **Performance:** Load testing, memory leaks, battery usage
- **Accessibility:** Screen reader, font scaling, color contrast

### 5.1 Error Handling
- [ ] Add try-catch blocks around all service calls
- [ ] Show user-friendly error messages
- [ ] Handle offline scenarios gracefully
- [ ] Add retry mechanisms for failed operations

### 5.2 Loading States
- [ ] Add loading indicators for all async operations
- [ ] Use `AsyncValue` from Riverpod consistently
- [ ] Show skeleton loaders where appropriate

### 5.3 Data Validation
- [ ] Validate all form inputs
- [ ] Check stock availability before sales
- [ ] Validate batch quantities and costs
- [ ] Prevent negative stock

### 5.4 Testing
- [ ] Unit tests for services
- [ ] Widget tests for critical screens
- [ ] Integration tests for key flows

---

## Implementation Order (Recommended)

### Sprint 1 (Week 1)
1. Phase 1.1 - Stock Detail Actions (Restock, View Movements, View Batches)
2. Phase 1.3 - Restock Service Integration
3. Phase 2.1 - Products Screen Real Data

### Sprint 2 (Week 2)
1. Phase 1.2 - Reset Password Service
2. Phase 1.4 - Batch Creation Service
3. Phase 2.2 - Stock Detail Real Data
4. Phase 2.3 - Batch Detail Real Data

### Sprint 3 (Week 3)
1. Phase 2.4 - Pending Items Real Data
2. Phase 2.5 - Dashboard Real Data
3. Phase 3.1 - Product Navigation Flow
4. Phase 3.2 - Batch Navigation Flow

### Sprint 4 (Week 4)
1. Phase 3.3 - Restock Navigation
2. Phase 3.4 - Sales Completed Actions
3. Phase 4.1 - Manage Users Enhancements

### Sprint 5 (Week 5)
1. Phase 4.2-4.4 - Additional Features
2. Phase 5 - Error Handling & Polish

---

## Technical Notes

### Service Providers Setup
Create Riverpod providers for all services:
```dart
// lib/core/providers/services_provider.dart
final restockServiceProvider = Provider<RestockService>((ref) {
  return RestockService(
    ref.watch(databaseProvider),
    ref.watch(syncQueueDaoProvider),
  );
});

final productionServiceProvider = Provider<ProductionService>((ref) {
  return ProductionService(
    ref.watch(databaseProvider),
    ref.watch(syncQueueDaoProvider),
  );
});
```

### ViewModel Pattern
For screens with complex state, create ViewModels:
```dart
// Example: ProductsViewModel
class ProductsViewModel extends StateNotifier<AsyncValue<List<ProductWithStock>>> {
  final ProductsDao productsDao;
  final InventoryService inventoryService;
  
  ProductsViewModel(this.productsDao, this.inventoryService) 
    : super(const AsyncValue.loading()) {
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    // Fetch and combine product + stock data
  }
}
```

### Navigation Parameters
Use a consistent pattern for passing data:
- For IDs: Pass `productId`, `batchId`, `movementId`
- For full objects: Pass when needed, but prefer IDs
- Use route parameters or constructor parameters consistently

---

## Dependencies to Add

```yaml
dependencies:
  # For printing receipts
  printing: ^5.13.0
  
  # For sharing
  share_plus: ^10.1.2
  
  # For better async state management (if not already using)
  # Already have flutter_riverpod ✓
```

---

## Success Criteria

- [ ] All TODO comments resolved
- [ ] All mock data replaced with real database queries
- [ ] All navigation flows working end-to-end
- [ ] All service integrations complete
- [ ] Error handling in place
- [ ] Loading states implemented
- [ ] App works offline (data persists locally)
- [ ] Sync queue processes correctly

---

## Estimated Timeline

- **Phase 1:** 2 weeks (Critical services)
- **Phase 2:** 1-2 weeks (Data integration)
- **Phase 3:** 1 week (Navigation)
- **Phase 4:** 1 week (Additional features)
- **Phase 5:** 1 week (Polish)

**Total: 6-7 weeks** for complete implementation

---

## Quick Start Checklist

Before starting, ensure:
- [ ] Database schema is complete
- [ ] All DAOs are generated (`dart run build_runner build`)
- [ ] Firebase is configured
- [ ] Riverpod providers are set up
- [ ] Current user context is available (auth state)

---

*Last Updated: Based on codebase verification report*

