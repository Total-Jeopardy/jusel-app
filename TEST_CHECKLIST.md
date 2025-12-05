# Jusel App - Comprehensive Test Checklist

**Purpose**: End-to-end testing checklist to validate all app functionality from initial setup to daily operations.

**How to Use**: 
- Check off each item as you test it
- Note any issues in the "Notes" column
- Test with both Boss and Apprentice roles where applicable
- Test both online and offline scenarios

---

## 📱 1. App Initialization & First Launch

### 1.1 App Startup
- [ ] App launches without crashes
- [ ] Firebase initializes correctly
- [ ] No console errors on startup
- [ ] App shows login screen if no user exists
- [ ] App shows appropriate dashboard if user already logged in (after restart)

### 1.2 First User Setup
- [ ] Navigate to first setup screen (if no users exist)
- [ ] Fill in all required fields (name, phone, email, password, role)
- [ ] Validation works (empty fields, invalid email, weak password)
- [ ] Create first user successfully
- [ ] User is created in Firebase Auth
- [ ] User is saved to local database
- [ ] User is saved to Firestore
- [ ] App navigates to correct dashboard based on role (boss/apprentice)
- [ ] Cannot create first user with "apprentice" role (if restricted)

---

## 🔐 2. Authentication

### 2.1 Login
- [ ] Login screen displays correctly
- [ ] Enter valid credentials → successful login
- [ ] Enter invalid email → shows error message
- [ ] Enter invalid password → shows error message
- [ ] Enter non-existent user → shows appropriate error
- [ ] Login button disabled while loading
- [ ] Loading indicator shows during login
- [ ] After successful login, navigates to correct dashboard (boss/apprentice)
- [ ] User data loads correctly after login
- [ ] Back button on login screen works (if applicable)

### 2.2 Logout
- [ ] Logout button accessible from account screen
- [ ] Logout shows confirmation or loading state
- [ ] Logout clears user session
- [ ] After logout, navigates to login screen
- [ ] Cannot access protected screens after logout
- [ ] Local data persists (for offline-first)

### 2.3 Password Management
- [ ] Reset password screen accessible
- [ ] Enter email → receives reset email (check Firebase console)
- [ ] Reset password shows success message
- [ ] Change password screen accessible (from account)
- [ ] Change password requires current password
- [ ] Change password validates new password match
- [ ] Change password updates successfully
- [ ] Error messages display for failed password changes
- [ ] Back navigation works on password screens

---

## 🧭 3. Navigation & Routing

### 3.1 Back Button Navigation
- [ ] Back button on all screens uses `safePop()` correctly
- [ ] Back button from nested screens returns to previous screen
- [ ] Back button from root screens navigates to dashboard (not crashes)
- [ ] System back button (Android) works correctly
- [ ] No GoRouter assertion errors when using back button
- [ ] PopScope works on dashboards (prevents accidental exit)

### 3.2 Bottom Navigation (Boss Dashboard)
- [ ] All 5 tabs accessible (Dashboard, Products, Sales, Stock, Reports)
- [ ] Tab switching works smoothly
- [ ] Tab state persists when navigating away and back
- [ ] Correct screen displays for each tab
- [ ] Tab icons and labels display correctly

### 3.3 Screen Navigation
- [ ] All navigation links/buttons work
- [ ] Navigation passes correct IDs (not full objects)
- [ ] Screens refresh after returning from mutations (add product, restock, etc.)
- [ ] Deep navigation works (e.g., Dashboard → Product → Stock Detail → Restock)
- [ ] Navigation stack doesn't grow indefinitely

---

## 📦 4. Product Management

### 4.1 Products List Screen
- [ ] Products list loads from database
- [ ] Current stock displays for each product
- [ ] Status pills display correctly (active/inactive/sold_out)
- [ ] Search functionality works (by name)
- [ ] Filter by status works
- [ ] Filter by category works
- [ ] Empty state shows when no products match filters
- [ ] Loading state shows while fetching
- [ ] Error state shows if fetch fails
- [ ] Pull-to-refresh works (if implemented)
- [ ] Tap product → navigates to Product Detail
- [ ] Tap product → navigates to Stock Detail (if applicable)

### 4.2 Add Product Screen
- [ ] Form fields display correctly
- [ ] Required fields marked appropriately
- [ ] Category dropdown shows all categories
- [ ] Subcategory dropdown updates based on category
- [ ] "Produced" checkbox works correctly
- [ ] Numeric inputs only accept numbers (units per pack, prices, initial stock)
- [ ] Validation works (empty name, invalid prices, etc.)
- [ ] Submit button disabled when form invalid
- [ ] Submit button shows loading state
- [ ] Product created successfully in local database
- [ ] Product enqueued to sync queue
- [ ] Success message displays
- [ ] Navigation returns to products list
- [ ] Products list refreshes showing new product
- [ ] Product appears in Firestore after sync (test sync separately)

### 4.3 Product Detail Screen
- [ ] Product detail loads by productId
- [ ] All product information displays correctly
- [ ] Current stock displays correctly
- [ ] Status displays with correct color
- [ ] Pricing information displays (selling price, cost price, margin)
- [ ] Recent movements display (last 5)
- [ ] Empty state for movements shows if none exist
- [ ] "Restock Product" button works → navigates to RestockScreen
- [ ] "Edit Product" button works (if implemented)
- [ ] "View Stock Movements" button works → navigates to StockHistoryScreen
- [ ] Back button works correctly
- [ ] Loading state shows while fetching
- [ ] Error state shows if product not found

---

## 📊 5. Stock Management

### 5.1 Stock Detail Screen
- [ ] Stock detail loads by productId
- [ ] Product information displays correctly
- [ ] Current stock displays correctly
- [ ] Stock status badge shows (In Stock/Low Stock/Out of Stock)
- [ ] Alert card shows for low stock
- [ ] Reorder suggestion calculates correctly
- [ ] Trend chart displays (if movements exist)
- [ ] Trend chart shows empty state (if no movements)
- [ ] Recent activity shows last 5 movements
- [ ] All action buttons work:
  - [ ] "Restock Product" → RestockScreen
  - [ ] "Add to Purchase List" → shows placeholder message
  - [ ] "View Production Batches" → BatchScreen (filtered)
  - [ ] "View All Movements" → StockHistoryScreen
  - [ ] "View Product Details" → ProductDetailScreen
- [ ] Loading state shows while fetching
- [ ] Error state shows if fetch fails
- [ ] Back button works correctly

### 5.2 Restock Screen
- [ ] Screen loads with product context (if productId provided)
- [ ] Product picker opens bottom sheet
- [ ] Product picker shows all active products
- [ ] Selecting product updates displayed info
- [ ] Current stock displays correctly
- [ ] Pack mode vs Unit mode toggle works
- [ ] Form fields accept only numeric input
- [ ] Validation works (empty quantities, invalid costs)
- [ ] Submit button disabled when invalid or no product selected
- [ ] Submit button shows loading state
- [ ] Restock creates stock movement in database
- [ ] Stock quantity updates correctly
- [ ] Restock enqueued to sync queue
- [ ] Success message displays
- [ ] Navigates to RestockSuccessScreen
- [ ] RestockSuccessScreen shows correct details
- [ ] "Back to Product" navigates to StockDetailScreen
- [ ] Stock detail shows updated stock after returning
- [ ] Back button works correctly

### 5.3 Stock History Screen
- [ ] Screen loads movements for productId
- [ ] Product name and current stock display in header
- [ ] Filter chips work (All, Sales, Restocks, Production, Adjustments)
- [ ] Movements grouped by day (Today, Yesterday, Date)
- [ ] Movement cards show correct information:
  - [ ] Type/icon
  - [ ] Date and time
  - [ ] Quantity (with +/- sign)
  - [ ] Reason (if available)
- [ ] Empty state shows when no movements
- [ ] Loading state shows while fetching
- [ ] Error state shows with retry button
- [ ] Retry button works
- [ ] Back button works correctly

---

## 🏭 6. Production Management

### 6.1 Batch List Screen
- [ ] Screen loads batches from database
- [ ] Product picker works (shows all products or filters)
- [ ] Date filtering works
- [ ] Sorting works (if implemented)
- [ ] Batch cards show correct information:
  - [ ] Product name
  - [ ] Date
  - [ ] Quantity produced
  - [ ] Total cost
  - [ ] Unit cost
  - [ ] Notes (if available)
- [ ] Empty state shows when no batches
- [ ] Loading state shows while fetching
- [ ] Error state shows if fetch fails
- [ ] "Add New Batch" button works → NewBatchScreen
- [ ] Tap batch card → navigates to BatchDetailScreen
- [ ] Back button works correctly

### 6.2 New Batch Screen
- [ ] Screen loads with product context (if productId provided)
- [ ] Product picker opens bottom sheet
- [ ] Product picker shows only produced products
- [ ] Selecting product updates displayed info
- [ ] Form fields accept only numeric input
- [ ] Cost breakdown fields work (ingredients, gas, oil, labor, etc.)
- [ ] Notes field works
- [ ] Validation works (empty quantity, invalid costs)
- [ ] Submit button disabled when invalid or no product selected
- [ ] Submit button shows loading state
- [ ] Batch created in database
- [ ] Stock movement created for production output
- [ ] Batch enqueued to sync queue
- [ ] Success message displays
- [ ] Navigates to BatchDetailScreen
- [ ] Batch list refreshes after returning
- [ ] Back button works correctly

### 6.3 Batch Detail Screen
- [ ] Screen loads batch by batchId
- [ ] Batch information displays correctly
- [ ] Product information displays
- [ ] Cost breakdown displays correctly
- [ ] Totals calculate correctly
- [ ] Unit cost calculates correctly
- [ ] Notes display (if available)
- [ ] Related movement card shows (if exists)
- [ ] "Related Movement" navigation works → StockHistoryScreen
- [ ] Loading state shows while fetching
- [ ] Error state shows if batch not found
- [ ] Back button works correctly

---

## 💰 7. Sales Management

### 7.1 Sales Screen
- [ ] Screen loads active products
- [ ] Products display with current stock
- [ ] Out-of-stock products disabled (or marked)
- [ ] Search functionality works
- [ ] Add to cart works
- [ ] Cart shows correct items
- [ ] Cart shows correct quantities
- [ ] Cart shows correct totals
- [ ] Cannot add more than available stock
- [ ] Error message shows if trying to exceed stock
- [ ] Remove item from cart works
- [ ] Update quantity in cart works
- [ ] Price overrides work (if boss role)
- [ ] Complete sale button works → SalesCompletedScreen
- [ ] Loading state shows while fetching products
- [ ] Error state shows if fetch fails
- [ ] Empty state shows when no products

### 7.2 Sales Completed Screen
- [ ] Screen shows sale summary
- [ ] All line items display correctly
- [ ] Totals calculate correctly
- [ ] Receipt information displays
- [ ] Print button works → generates PDF
- [ ] Share button works → shares receipt
- [ ] Print/Share show loading states
- [ ] Error handling for print/share
- [ ] "Start New Sale" button works → clears cart, returns to SalesScreen
- [ ] "Back to Dashboard" navigates to correct dashboard
- [ ] Sale recorded in database
- [ ] Stock decremented correctly
- [ ] Sale enqueued to sync queue
- [ ] Stock movements created for each item

---

## 📈 8. Dashboards

### 8.1 Boss Dashboard
- [ ] Dashboard loads correctly
- [ ] Low stock alerts display
- [ ] Low stock alerts show correct products
- [ ] Tap low stock alert → navigates to StockDetailScreen
- [ ] Inventory metrics display (total value, etc.)
- [ ] Sales metrics display (revenue, profit, etc.)
- [ ] Metrics calculate correctly
- [ ] Quick action cards work:
  - [ ] Add Product
  - [ ] New Sale
  - [ ] Restock
  - [ ] New Batch
- [ ] Navigation to all tabs works
- [ ] Account button works → AccountScreen
- [ ] Loading state shows while fetching
- [ ] Error state shows if fetch fails
- [ ] Empty states show appropriately
- [ ] PopScope prevents accidental exit

### 8.2 Apprentice Dashboard
- [ ] Dashboard loads correctly
- [ ] Low stock alerts display
- [ ] Tap low stock alert → navigates to StockDetailScreen
- [ ] Limited features accessible (no full metrics)
- [ ] Quick actions appropriate for role
- [ ] Navigation works
- [ ] Account button works
- [ ] Loading/error/empty states work
- [ ] PopScope prevents accidental exit

---

## 👤 9. Account & Settings

### 9.1 Account Screen
- [ ] User information displays correctly
- [ ] Role displays correctly
- [ ] All menu items accessible:
  - [ ] Edit Profile
  - [ ] Change Password
  - [ ] Manage Users (boss only)
  - [ ] Pending Items
  - [ ] Sync Status
  - [ ] Shop Settings
  - [ ] Notifications Settings
  - [ ] Low Stock Threshold
  - [ ] App Theme
  - [ ] About Jusel
- [ ] Logout button works
- [ ] Back button works (with PopScope)
- [ ] Loading/error states work

### 9.2 Manage Users Screen
- [ ] Screen loads all users from database
- [ ] Users display with correct information (name, email, role, status)
- [ ] Role chips display correctly
- [ ] Activate/Deactivate toggle works
- [ ] Toggle shows loading state
- [ ] User status updates in database
- [ ] List refreshes after status change
- [ ] "Add User" button works → opens bottom sheet
- [ ] Add user form works
- [ ] New user created in Firebase Auth
- [ ] New user saved to local database
- [ ] New user saved to Firestore
- [ ] List refreshes after adding user
- [ ] "View Activity" shows placeholder (if not implemented)
- [ ] "Reset Password" works (if implemented)
- [ ] Loading/error/empty states work
- [ ] Back button works correctly

### 9.3 Pending Items Screen
- [ ] Screen loads pending operations from queue
- [ ] Operations display with correct information:
  - [ ] Operation type
  - [ ] Timestamp
  - [ ] Status
  - [ ] Payload preview
- [ ] Empty state shows when no pending operations
- [ ] "Sync All Now" button works
- [ ] Sync shows progress/loading state
- [ ] Sync completes successfully
- [ ] List refreshes after sync
- [ ] Error handling for sync failures
- [ ] Loading/error states work
- [ ] Back button works correctly

### 9.4 Other Settings Screens
- [ ] Edit Profile: loads and saves user info
- [ ] Change Password: works (tested in Auth section)
- [ ] Shop Settings: loads and saves settings
- [ ] Notifications Settings: toggles work
- [ ] Low Stock Threshold: updates threshold
- [ ] App Theme: theme changes apply
- [ ] About Jusel: displays app information
- [ ] All settings screens have working back buttons

---

## 🔄 10. Sync & Offline Functionality

### 10.1 Offline Operations
- [ ] Turn off device internet/airplane mode
- [ ] Add product → saves to local database
- [ ] Add product → enqueued to sync queue
- [ ] Restock product → saves locally, enqueued
- [ ] Create batch → saves locally, enqueued
- [ ] Complete sale → saves locally, enqueued
- [ ] All operations work offline
- [ ] Pending items screen shows queued operations

### 10.2 Sync Operations
- [ ] Turn internet back on
- [ ] Open Pending Items screen
- [ ] Tap "Sync All Now"
- [ ] Sync processes all queued operations
- [ ] Operations sync to Firestore correctly
- [ ] Operations removed from queue after successful sync
- [ ] Failed operations remain in queue
- [ ] Error messages display for failed syncs
- [ ] Verify data in Firestore matches local database

### 10.3 Sync Verification
- [ ] Product create syncs correctly
- [ ] Restock syncs correctly
- [ ] Production batch syncs correctly
- [ ] Sale syncs correctly
- [ ] Price change syncs correctly (if implemented)
- [ ] User create syncs correctly
- [ ] All operation types have correct payload structure

---

## 🎨 11. UI/UX & States

### 11.1 Loading States
- [ ] All screens show loading indicators while fetching data
- [ ] Loading states are visually clear
- [ ] Buttons show loading states during operations
- [ ] No flickering or layout shifts during loading

### 11.2 Error States
- [ ] Error messages are user-friendly
- [ ] Error states show retry options where appropriate
- [ ] Network errors handled gracefully
- [ ] Validation errors show inline
- [ ] Error messages don't expose technical details to users

### 11.3 Empty States
- [ ] Empty states show helpful messages
- [ ] Empty states suggest actions (e.g., "Add your first product")
- [ ] Empty states are visually clear

### 11.4 Form Validation
- [ ] All forms validate input
- [ ] Validation errors show immediately
- [ ] Submit buttons disabled when invalid
- [ ] Numeric inputs only accept numbers
- [ ] Required fields marked clearly

---

## 🔍 12. Edge Cases & Error Scenarios

### 12.1 Data Edge Cases
- [ ] Product with zero stock
- [ ] Product with negative stock (if possible)
- [ ] Product with very large stock numbers
- [ ] Product with very long names
- [ ] Product with special characters in name
- [ ] Batch with zero quantity
- [ ] Sale with zero items in cart
- [ ] Sale with very large quantities
- [ ] Very old dates in history
- [ ] Future dates (if possible)

### 12.2 Network Edge Cases
- [ ] Slow network connection
- [ ] Intermittent connectivity
- [ ] Complete network failure
- [ ] Network timeout scenarios
- [ ] Firebase connection issues

### 12.3 User Input Edge Cases
- [ ] Very long text inputs
- [ ] Special characters in inputs
- [ ] Copy/paste into numeric fields
- [ ] Multiple rapid taps on buttons
- [ ] Form submission while loading
- [ ] Navigation while operation in progress

### 12.4 App State Edge Cases
- [ ] App backgrounded during operation
- [ ] App killed during operation
- [ ] App restarted after crash
- [ ] Multiple users logged in (if possible)
- [ ] User role changed while app open

---

## 🧪 13. Performance & Stability

### 13.1 Performance
- [ ] App launches quickly (< 3 seconds)
- [ ] Screens load quickly (< 1 second for data)
- [ ] Scrolling is smooth (60fps)
- [ ] No memory leaks (test over extended use)
- [ ] Database queries are fast
- [ ] Large lists render efficiently

### 13.2 Stability
- [ ] No crashes during normal use
- [ ] No crashes during edge cases
- [ ] App handles errors gracefully
- [ ] No console errors in production mode
- [ ] App doesn't freeze or become unresponsive

---

## 🔐 14. Security & Permissions

### 14.1 Authentication Security
- [ ] Passwords are not stored in plain text
- [ ] Session tokens handled securely
- [ ] Logout clears sensitive data
- [ ] Cannot access protected screens without auth

### 14.2 Role-Based Access
- [ ] Boss sees all features
- [ ] Apprentice sees limited features
- [ ] Role restrictions enforced
- [ ] Cannot access restricted features via direct navigation

### 14.3 Data Security
- [ ] Sensitive data not logged
- [ ] Database encrypted (if implemented)
- [ ] API keys not exposed

---

## 📱 15. Platform-Specific Testing

### 15.1 Android
- [ ] App installs correctly
- [ ] Permissions requested appropriately
- [ ] System back button works
- [ ] App works on different Android versions
- [ ] App works on different screen sizes
- [ ] Keyboard handling works correctly

### 15.2 iOS (if applicable)
- [ ] App installs correctly
- [ ] Permissions requested appropriately
- [ ] Gestures work correctly
- [ ] App works on different iOS versions
- [ ] App works on different screen sizes

---

## ✅ 16. Final Verification

### 16.1 Complete User Flows
- [ ] **New User Flow**: First setup → Login → Add Product → Restock → Create Batch → Complete Sale → View Dashboard
- [ ] **Daily Operations Flow**: Login → View Low Stock → Restock → Complete Sales → Check Metrics
- [ ] **Production Flow**: Login → View Products → Create Batch → View Batch Details → Check Stock Update
- [ ] **Sales Flow**: Login → Add Items to Cart → Apply Overrides → Complete Sale → Print Receipt → View Updated Stock

### 16.2 Data Integrity
- [ ] All operations persist correctly
- [ ] Stock calculations are accurate
- [ ] Financial calculations are accurate
- [ ] Timestamps are correct
- [ ] Relationships between data are maintained

### 16.3 Documentation
- [ ] All features work as documented
- [ ] User can complete tasks without confusion
- [ ] Error messages are helpful
- [ ] UI is intuitive

---

## 📝 Testing Notes Template

**Date**: _______________
**Tester**: _______________
**App Version**: _______________
**Device/OS**: _______________

### Issues Found:
1. **Issue**: 
   - **Location**: 
   - **Steps to Reproduce**: 
   - **Expected**: 
   - **Actual**: 
   - **Severity**: Critical / High / Medium / Low

2. **Issue**: 
   - **Location**: 
   - **Steps to Reproduce**: 
   - **Expected**: 
   - **Actual**: 
   - **Severity**: Critical / High / Medium / Low

### Test Coverage:
- Total Items: ______
- Passed: ______
- Failed: ______
- Skipped: ______
- Pass Rate: ______%

---

## 🎯 Priority Testing (If Time Limited)

If you have limited time, focus on these critical paths:

1. **Authentication** (Section 2) - Users must be able to log in
2. **Product Management** (Section 4.2) - Core functionality
3. **Stock Management** (Section 5.2) - Core functionality  
4. **Sales** (Section 7) - Revenue generation
5. **Sync** (Section 10) - Data integrity
6. **Navigation** (Section 3) - User experience

---

**Last Updated**: 2024-12-19
**Version**: 1.0

