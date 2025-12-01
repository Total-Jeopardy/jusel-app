# Jusel App - Complete Architecture Overview

## 📱 Application Summary
A mobile sales tracking app built with Flutter, Firebase, and Riverpod using MVVM architecture. Designed for offline-first operation with sync capabilities.

---

## 🏗️ Architecture Overview

### **MVVM Pattern**
- **Model**: Data models, database tables, DAOs
- **View**: UI screens and widgets
- **ViewModel**: Business logic and state management (Riverpod StateNotifiers)
- **Repository**: Data access layer (Firebase + Local DB)

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
│
├── core/                              # Core functionality
│   ├── database/                      # Drift database layer
│   │   ├── app_database.dart         # Main database class
│   │   ├── tables/                    # Database table definitions
│   │   │   ├── users_table.dart
│   │   │   ├── products_table.dart
│   │   │   ├── stock_movements_table.dart
│   │   │   ├── production_batches_table.dart
│   │   │   ├── product_price_history_table.dart
│   │   │   └── pending_sync_queue_table.dart
│   │   └── daos/                      # Data Access Objects
│   │       ├── users_dao.dart
│   │       ├── products_dao.dart
│   │       ├── stock_movements_dao.dart
│   │       ├── production_batches_dao.dart
│   │       ├── product_price_history_dao.dart
│   │       └── pending_sync_queue_dao.dart
│   │
│   ├── services/                      # Business logic services
│   │   ├── sales_service.dart        # Handle sales operations
│   │   ├── inventory_service.dart    # Stock calculations
│   │   ├── production_service.dart   # Production batch management
│   │   ├── restock_service.dart      # Restocking operations
│   │   ├── price_override_service.dart # Boss price overrides
│   │   └── metrics_service.dart      # Analytics & metrics
│   │
│   ├── sync/                          # Offline sync system
│   │   └── sync_orchestrator.dart    # Sync queue management
│   │
│   ├── providers/                     # Riverpod providers
│   │   ├── global_providers.dart     # Theme, router providers
│   │   └── database_provider.dart    # Database providers
│   │
│   ├── router/                        # Navigation
│   │   └── router.dart               # GoRouter configuration
│   │
│   ├── ui/                            # Reusable UI components
│   │   └── components/
│   │       ├── jusel_app_bar.dart
│   │       ├── jusel_button.dart
│   │       ├── jusel_card.dart
│   │       └── jusel_text_field.dart
│   │
│   └── utils/                          # Utilities
│       └── theme.dart                 # Design system & themes
│
├── data/                              # Data layer
│   ├── models/                        # Data models
│   │   └── app_user.dart             # User model
│   └── repositories/                  # Data repositories
│       └── auth_repository.dart      # Authentication repository
│
└── features/                          # Feature modules (MVVM)
    ├── auth/                          # Authentication
    │   ├── view/
    │   │   └── login_screen.dart
    │   └── viewmodel/
    │       └── auth_viewmodel.dart
    │
    ├── dashboard/                      # Dashboards
    │   └── view/
    │       ├── boss_dashboard.dart
    │       └── apprentice_dashboard.dart
    │
    ├── production/                     # Production management
    │   ├── providers.dart
    │   ├── viewmodel/
    │   │   ├── production_viewmodel.dart
    │   │   └── production_state.dart
    │   └── view/
    │
    ├── sales/                          # Sales module
    │   ├── view/
    │   ├── viewmodel/
    │   └── widgets/
    │
    ├── products/                        # Product management
    │   ├── view/
    │   ├── viewmodel/
    │   └── widgets/
    │
    ├── stock/                           # Stock management
    │   ├── view/
    │   ├── viewmodel/
    │   └── widgets/
    │
    ├── reports/                        # Reports & analytics
    │   ├── view/
    │   └── viewmodel/
    │
    └── settings/                        # App settings
        ├── view/
        └── viewmodel/
```

---

## 🔄 Application Flow

### **1. App Initialization** (`main.dart`)
```
1. WidgetsFlutterBinding.ensureInitialized()
2. Firebase.initializeApp()
3. ProviderScope wraps MainApp
4. MaterialApp.router with GoRouter
5. Theme system (light/dark/system)
```

### **2. Authentication Flow**
```
LoginScreen → AuthViewModel → AuthRepository
    ↓
Firebase Auth (sign in)
    ↓
Load user from Firestore
    ↓
Save to local Drift DB (offline support)
    ↓
Navigate to appropriate dashboard (boss/apprentice)
```

### **3. Data Flow (MVVM)**
```
View (UI)
    ↓
ViewModel (StateNotifier)
    ↓
Service (Business Logic)
    ↓
DAO (Data Access)
    ↓
Drift Database (Local) + Firebase (Sync)
```

---

## 🗄️ Database Schema

### **Tables**

1. **UsersTable**
   - id, name, phone, email, role (boss/apprentice), isActive, timestamps

2. **ProductsTable**
   - id, name, category, subcategory, isProduced, prices, stock, status

3. **StockMovementsTable**
   - id, productId, type, quantityUnits, quantityPacks, batchId, costs, reason, userId, timestamp

4. **ProductionBatchesTable**
   - id, productId, quantityProduced, cost breakdown (ingredients, gas, oil, labor, transport, packaging, other), totalCost, unitCost, notes

5. **ProductPriceHistoryTable**
   - id, productId, old/new selling/cost prices, changeType, reason, timestamp

6. **PendingSyncQueueTable**
   - id, operationType, payload (JSON), status, retries, errorMessage, timestamps

---

## 🔧 Core Services

### **1. SalesService**
- Validates stock availability
- Records sales as stock movements
- Calculates profit (revenue - cost)

### **2. InventoryService**
- Calculates current stock from movements
- Computes total inventory value
- Detects low-stock products

### **3. ProductionService**
- Creates production batches with cost breakdown
- Calculates weighted average cost per unit
- Tracks production history

### **4. RestockService**
- Restock by packs (for drinks/water)
- Restock by units (for loose items)
- Updates product cost prices

### **5. PriceOverrideService**
- Boss-only price overrides
- Logs price changes to history
- Queues for sync to Firestore

### **6. SyncOrchestrator**
- Manages offline operation queue
- Syncs to Firestore when online
- Handles retries and failures
- Supports: sales, restocks, production, price changes, product CRUD

---

## 🎨 UI Components (Design System)

### **Jusel Design System**
- **Colors**: Primary, secondary, accent, muted, status colors
- **Spacing**: Consistent spacing scale (s0 to s64)
- **Typography**: Inter font family with defined text styles
- **Components**:
  - `JuselAppBar` - Custom app bar
  - `JuselButton` - Button with variants (primary, secondary, outline, ghost)
  - `JuselCard` - Card with padding options
  - `JuselTextField` - Text input with password support

---

## 🚀 Key Features

### **✅ Implemented**
1. ✅ Authentication (Firebase Auth + local caching)
2. ✅ Database layer (Drift with 6 tables)
3. ✅ Core services (Sales, Inventory, Production, Restock, Price Override)
4. ✅ Offline sync system (queue-based)
5. ✅ UI components (Design system)
6. ✅ Routing (GoRouter)
7. ✅ Theme system (Light/Dark/System)

### **🚧 In Progress / Planned**
- Production views
- Sales views
- Product management views
- Stock management views
- Reports & analytics
- Settings

---

## 📊 Data Synchronization

### **Offline-First Architecture**
1. All operations write to local Drift database first
2. Operations are queued in `PendingSyncQueueTable`
3. `SyncOrchestrator` syncs queue to Firestore when online
4. Supports retry logic and error handling
5. Sync operations: sales, restocks, production, price changes, product CRUD

---

## 🔐 User Roles

### **Boss**
- Full access to all features
- Can override prices
- View all reports and analytics

### **Apprentice**
- Limited access
- Can record sales
- Can view assigned products

---

## 🛠️ Technology Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Database**: Drift (SQLite)
- **Backend**: Firebase (Auth, Firestore)
- **Navigation**: GoRouter
- **Architecture**: MVVM

---

## 📝 Next Steps

1. Complete feature views (Production, Sales, Products, Stock, Reports)
2. Implement metrics/analytics dashboard
3. Add settings screen
4. Enhance error handling and user feedback
5. Add unit tests
6. Performance optimization

---

## ✅ Current Status

**All core infrastructure is in place:**
- ✅ Database schema complete
- ✅ All DAOs implemented
- ✅ All services implemented
- ✅ Sync system ready
- ✅ UI components ready
- ✅ Authentication flow ready
- ✅ Routing configured

**Ready for feature development!**

