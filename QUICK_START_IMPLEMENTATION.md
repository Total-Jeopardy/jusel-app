# Quick Start Implementation Guide

## Top 5 Critical Items to Implement First

These are the highest-impact items that will make the app functional.

---

### 1. Wire Stock Detail "Restock Product" Button ⚡
**Impact:** HIGH | **Time:** 30 minutes

**File:** `lib/features/stock/view/stock_detail_screen.dart` (Line 55)

```dart
// Replace TODO with:
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RestockScreen(
        productId: productId, // Add productId to StockDetailScreen params
        productName: productName,
        category: category,
        currentStock: stockUnits,
      ),
    ),
  );
},
```

**Steps:**
1. Add `productId` parameter to `StockDetailScreen` constructor
2. Update all navigation calls to pass `productId`
3. Wire button to navigate to `RestockScreen`

**Success Criteria:**
- ✅ Tapping "Restock Product" navigates to `RestockScreen`
- ✅ `RestockScreen` receives `productId`, `productName`, `category`, `currentStock`
- ✅ All existing navigation to `StockDetailScreen` updated to pass `productId`
- ✅ No compilation errors
- ✅ Manual test: Navigate from dashboard alert → Stock Detail → Restock button works

**Test Strategy:**
- Manual: Navigate from Products screen (low stock item) → Stock Detail → Tap Restock
- Manual: Navigate from Dashboard alert → Stock Detail → Tap Restock
- Verify: `RestockScreen` displays correct product name and current stock

---

### 2. Connect Products Screen to Real Data ⚡
**Impact:** HIGH | **Time:** 2-3 hours

**File:** `lib/features/products/view/products_screen.dart`

**Create ViewModel:**
```dart
// lib/features/products/viewmodel/products_viewmodel.dart
class ProductsViewModel extends StateNotifier<AsyncValue<List<ProductDisplay>>> {
  final ProductsDao productsDao;
  final InventoryService inventoryService;
  
  ProductsViewModel(this.productsDao, this.inventoryService) 
    : super(const AsyncValue.loading()) {
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await productsDao.getAllProducts();
      final stockMap = await inventoryService.getAllCurrentStock();
      
      final display = products.map((p) {
        final stock = stockMap[p.id] ?? 0;
        return ProductDisplay(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.currentSellingPrice,
          cost: p.currentCostPrice,
          stock: stock,
          status: _calculateStatus(stock),
        );
      }).toList();
      
      state = AsyncValue.data(display);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  ProductStatus _calculateStatus(int stock) {
    if (stock == 0) return ProductStatus.out;
    if (stock <= 5) return ProductStatus.low;
    return ProductStatus.good;
  }
}
```

**Update ProductsScreen:**
- Replace hardcoded `_products` list
- Use `ref.watch(productsViewModelProvider)`
- Handle loading/error states

**Success Criteria:**
- ✅ Products list populated from `ProductsDao.getAllProducts()`
- ✅ Stock counts calculated via `InventoryService.getAllCurrentStock()`
- ✅ Status badges (good/low/out) reflect real stock levels
- ✅ Loading indicator shows while fetching
- ✅ Error state displays if fetch fails
- ✅ Search and filter work with real data
- ✅ Manual test: Products screen shows actual products from database

**Test Strategy:**
- **Smoke test:** Open Products screen, verify products load from DB
- **Data test:** Add product via Add Product screen, verify it appears in list
- **Stock test:** Restock a product, verify stock count updates in Products list
- **Status test:** Verify low stock (≤5) shows "Low" badge, out of stock (0) shows "Out"
- **Error test:** Disconnect DB/network, verify error state displays

---

### 3. Wire Restock Service Integration ⚡
**Impact:** HIGH | **Time:** 1-2 hours

**File:** `lib/features/stock/view/restock_screen.dart` (Line 180)

```dart
// Add to RestockScreen:
final restockService = ref.watch(restockServiceProvider);
final currentUser = ref.watch(authViewModelProvider).valueOrNull;

// In save handler:
try {
  if (isPackMode) {
    await restockService.restockFromPacks(
      productId: productId,
      packCount: packCount,
      packPrice: packPrice,
      createdByUserId: currentUser!.uid,
    );
  } else {
    await restockService.restockByUnits(
      productId: productId,
      units: units,
      costPerUnit: costPerUnit,
      createdByUserId: currentUser!.uid,
    );
  }
  
  // Navigate to success screen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => RestockSuccessScreen(
        productName: productName,
        category: category,
        unitsAdded: totalUnits,
        newTotalStock: currentStock + totalUnits,
        costPerUnit: costPerUnit,
        inventoryValueAdded: totalUnits * costPerUnit,
        restockedBy: currentUser.name,
        restockedOn: DateTime.now(),
      ),
    ),
  );
} catch (e) {
  // Show error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.toString()}')),
  );
}
```

---

### 4. Connect Stock Detail to Real Data ⚡
**Impact:** MEDIUM | **Time:** 2 hours

**File:** `lib/features/stock/view/stock_detail_screen.dart`

**Update constructor:**
```dart
class StockDetailScreen extends StatelessWidget {
  final String productId; // Add this
  
  const StockDetailScreen({
    super.key,
    required this.productId,
    // Keep other params for backward compatibility during transition
  });
}
```

**Add data fetching:**
```dart
// Use ConsumerWidget or add Riverpod
@override
Widget build(BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      final productAsync = ref.watch(productProvider(productId));
      final stockAsync = ref.watch(stockProvider(productId));
      final movementsAsync = ref.watch(movementsProvider(productId));
      
      return productAsync.when(
        data: (product) => _buildContent(product, stockAsync, movementsAsync),
        loading: () => CircularProgressIndicator(),
        error: (e, st) => Text('Error: $e'),
      );
    },
  );
}
```

**Create providers:**
```dart
final productProvider = FutureProvider.family<ProductsTableData, String>((ref, productId) {
  return ref.watch(databaseProvider).productsDao.getProduct(productId);
});

final stockProvider = FutureProvider.family<int, String>((ref, productId) {
  return ref.watch(inventoryServiceProvider).getCurrentStock(productId);
});
```

**Success Criteria:**
- ✅ `StockDetailScreen` accepts `productId` parameter
- ✅ Product data fetched from `ProductsDao.getProduct(productId)`
- ✅ Current stock calculated via `InventoryService.getCurrentStock(productId)`
- ✅ Recent activity shows real movements from `StockMovementsDao.getMovementsForProduct()`
- ✅ All hardcoded data replaced with real queries
- ✅ Loading states show while fetching
- ✅ Manual test: Navigate with productId → Screen shows real product data

**Test Strategy:**
- **Data fetch:** Navigate with valid productId → Verify product name, category, stock display
- **Stock calculation:** Restock product → Navigate to Stock Detail → Verify updated stock count
- **Recent activity:** Perform sale/restock → Navigate to Stock Detail → Verify movement appears
- **Error handling:** Navigate with invalid productId → Verify error state
- **Loading state:** Verify loading indicator during data fetch

---

### 5. Wire Reset Password Service ⚡
**Impact:** MEDIUM | **Time:** 1 hour

**File:** `lib/features/auth/view/reset_password_screen.dart` (Line 160)

**Add to AuthRepository:**
```dart
// lib/data/repositories/auth_repository.dart
Future<void> resetUserPassword({
  required String userId,
  required String newPassword,
}) async {
  // Option 1: Use Firebase Admin SDK (requires backend)
  // Option 2: Use Firebase Auth updatePassword (requires user to be logged in)
  // Option 3: Send password reset email (simpler)
  
  // For now, if you have admin access:
  try {
    // This requires Firebase Admin SDK on backend
    // Or use Firebase Console API
    throw UnimplementedError('Requires backend implementation');
  } catch (e) {
    throw Exception('Failed to reset password: $e');
  }
}
```

**Wire in ResetPasswordScreen:**
```dart
void _handleReset() async {
  final authRepo = ref.read(authRepositoryProvider);
  final userId = widget.userId; // Add userId to screen params
  
  try {
    await authRepo.resetUserPassword(
      userId: userId,
      newPassword: _newController.text,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully'),
          backgroundColor: JuselColors.success,
        ),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: JuselColors.destructive,
        ),
      );
    }
  }
}
```

**Success Criteria:**
- ✅ `ResetPasswordScreen._handleReset()` calls `AuthRepository.resetUserPassword()`
- ✅ Password updated in Firebase Auth (or backend service)
- ✅ Success message displayed
- ✅ Screen navigates back on success
- ✅ Error handling shows clear error messages
- ✅ Manual test: Reset password for test user → Verify password change

**Test Strategy:**
- **Happy path:** Reset password with valid input → Verify success message → Test login with new password
- **Validation:** Try mismatched passwords → Verify error message
- **Validation:** Try password < 6 chars → Verify error message
- **Error handling:** Simulate service failure → Verify error message displays
- **Security:** Verify old password no longer works after reset

---

## Service Provider Setup (Do This First!)

**File:** `lib/core/providers/services_provider.dart` (create if doesn't exist)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/services/restock_service.dart';
import 'package:jusel_app/core/services/production_service.dart';
import 'package:jusel_app/core/services/inventory_service.dart';
import 'package:jusel_app/core/database/daos/pending_sync_queue_dao.dart';

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService(ref.watch(databaseProvider));
});

final syncQueueDaoProvider = Provider<PendingSyncQueueDao>((ref) {
  return ref.watch(databaseProvider).pendingSyncQueueDao;
});

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

---

## Navigation Helper Pattern

Create a navigation helper to avoid repetitive code:

**File:** `lib/core/utils/navigation_helper.dart`

```dart
class NavigationHelper {
  static void toStockDetail(BuildContext context, {
    required String productId,
    String? productName,
    String? category,
  }) {
    // Fetch product data if needed, then navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StockDetailScreen(productId: productId),
      ),
    );
  }
  
  static void toProductDetail(BuildContext context, String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: productId),
      ),
    );
  }
  
  // Add more helpers as needed
}
```

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

## Common Pitfalls to Avoid

1. **Don't forget to handle loading states** - Users need feedback
2. **Don't skip error handling** - Always wrap service calls in try-catch
3. **Don't hardcode user IDs** - Get from auth state
4. **Don't forget to refresh data** - After mutations, reload affected screens
5. **Don't mix mock and real data** - Complete the transition fully

---

## Next Steps After Quick Start

Once these 5 items are done, proceed with:
1. Phase 2 from ROADMAP.md (Data Layer Integration)
2. Phase 3 (Navigation Improvements)
3. Phase 4 (Additional Features)
4. Phase 5 (Polish)

---

*Start with Item #1 - it's the quickest win!*

