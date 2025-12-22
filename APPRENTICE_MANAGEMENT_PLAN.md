# Apprentice Management Implementation Plan

## Goal
Restrict apprentice account creation so that:
- Only **bosses** can sign up/create accounts
- **Apprentices** can only be added by bosses (not sign up independently)
- **Apprentices** can only log in (not sign up)
- Every apprentice account is tied to a boss account

---

## Phase 1: Database Schema Changes

### 1.1 Update UsersTable Schema
**File**: `lib/core/database/tables/users_table.dart`

**Changes**:
- Add `bossId` column (nullable TextColumn) to link apprentices to their boss
  - `bossId` should be `null` for boss accounts
  - `bossId` should contain the boss's UID for apprentice accounts

**Migration**:
- Update `app_database.dart` schema version (increment from current version)
- Add migration to add `boss_id` column to `users_table`
- Set existing apprentices' `bossId` to `null` initially (or handle migration logic)

---

## Phase 2: Data Model Updates

### 2.1 Update AppUser Model
**File**: `lib/data/models/app_user.dart`

**Changes**:
- Add `bossId` field (String? nullable)
- Update `toJson()` to include `bossId`
- Update `fromJson()` to read `bossId`

### 2.2 Update UsersTableData
**File**: Generated file (via build_runner)
- Will automatically include `bossId` after schema update

---

## Phase 3: Authentication Flow Changes

### 3.1 Update FirstSetupScreen (Signup Screen)
**File**: `lib/features/auth/view/first_setup_screen.dart`

**Changes**:
- Remove role dropdown/selection
- Hardcode role to `'boss'` only
- Update UI text: "Create your shop account" or "Create boss account"
- Remove apprentice option from role selection

**Code Changes**:
```dart
// Remove: String _role = 'boss';
// Change to: const String _role = 'boss';
// Remove role dropdown entirely
// Update signup calls to always pass role: 'boss'
```

### 3.2 Update AuthRepository
**File**: `lib/data/repositories/auth_repository.dart`

**Changes**:
- Update `signUpUser()` method to accept optional `bossId` parameter
- When `bossId` is provided, set it in Firestore and local DB
- When `bossId` is `null`, ensure role is 'boss' (validation)

**New Method**:
- Add `signUpApprentice()` method that:
  - Requires `bossId` parameter
  - Sets role to 'apprentice'
  - Creates account with boss relationship

### 3.3 Update AuthViewModel
**File**: `lib/features/auth/viewmodel/auth_viewmodel.dart`

**Changes**:
- Update `signUpFirstUser()` to only allow 'boss' role
- Update `signUpAdditionalUser()` to only allow 'boss' role
- Add new method `createApprentice()` that:
  - Gets current user (must be boss)
  - Validates current user is boss
  - Calls repository with bossId

### 3.4 Update Login Validation
**File**: `lib/features/auth/view/login_screen.dart`

**Changes**:
- No changes needed - login already works for both roles
- Apprentices can log in if their account exists (created by boss)

---

## Phase 4: UI Changes - Add Apprentice Feature

### 4.1 Update ManageUsersScreen
**File**: `lib/features/account/view/manage_users_screen.dart`

**Changes**:
- Modify "Create User" button to "Add Apprentice" (only show for bosses)
- Update `_NewUserSheet` to:
  - Remove role selection dropdown
  - Hardcode role to 'apprentice'
  - Get current boss's UID automatically
  - Update form title: "Add New Apprentice"
  - Update button text: "Add Apprentice"

**Validation**:
- Only allow bosses to access this screen
- Show error if non-boss tries to add apprentice

### 4.2 Update AccountScreen
**File**: `lib/features/account/view/account_screen.dart`

**Changes**:
- Hide "Manage Users" tile for apprentices (already done via `isApprentice` check)
- Ensure only bosses can see/access user management

---

## Phase 5: Repository & DAO Updates

### 5.1 Update UsersDao
**File**: `lib/core/database/daos/users_dao.dart`

**Changes**:
- Update `insertUser()` to accept `bossId` parameter
- Update `createUser()` method signature
- Add query method: `getApprenticesByBoss(String bossId)`
- Add query method: `getBossByApprentice(String apprenticeId)`

### 5.2 Update AuthRepository
**File**: `lib/data/repositories/auth_repository.dart`

**Changes**:
- Update `signUpUser()` to save `bossId` to Firestore
- Update `signUpUser()` to save `bossId` to local DB via UsersDao
- Add validation: if `bossId` is null, role must be 'boss'
- Add validation: if `bossId` is provided, role must be 'apprentice'

---

## Phase 6: Sync & Firestore Updates

### 6.1 Update Firestore Schema
**File**: `lib/data/repositories/auth_repository.dart` (Firestore writes)

**Changes**:
- Include `bossId` field when creating users in Firestore
- Update sync logic to handle `bossId` field

### 6.2 Update Sync Orchestrator
**File**: `lib/core/sync/sync_orchestrator.dart`

**Changes**:
- Ensure `bossId` is synced when creating/updating users
- Handle `bossId` in user sync operations

---

## Phase 7: Validation & Security

### 7.1 Add Validation Rules
**Files**: Multiple

**Validations**:
1. **Signup Validation**:
   - Only 'boss' role allowed during signup
   - Reject signup attempts with 'apprentice' role

2. **Apprentice Creation Validation**:
   - Current user must be 'boss'
   - `bossId` must match current user's UID
   - Role must be 'apprentice'

3. **Login Validation**:
   - Apprentices can log in if account exists
   - No additional restrictions needed

### 7.2 Update Router Guards
**File**: `lib/core/router/router.dart`

**Changes**:
- No changes needed - existing guards should work
- Apprentices already have their own dashboard route

---

## Phase 8: UI/UX Improvements

### 8.1 Update FirstSetupScreen UI
**File**: `lib/features/auth/view/first_setup_screen.dart`

**Changes**:
- Remove role dropdown
- Update title: "Create Your Shop Account"
- Update description: "Set up your shop as the owner"
- Simplify form (remove role field)

### 8.2 Update ManageUsersScreen UI
**File**: `lib/features/account/view/manage_users_screen.dart`

**Changes**:
- Change button text: "Add Apprentice" instead of "Create User"
- Update form title in `_NewUserSheet`: "Add New Apprentice"
- Add helper text: "Apprentices can log in with the credentials you provide"
- Show boss's name in apprentice list (if needed)

### 8.3 Add Visual Indicators
**Files**: `lib/features/account/view/manage_users_screen.dart`

**Changes**:
- Show boss's name next to each apprentice
- Add badge/indicator showing apprentice belongs to which boss
- Filter apprentices by current boss (if multiple bosses exist)

---

## Phase 9: Migration & Data Cleanup

### 9.1 Database Migration
**File**: `lib/core/database/app_database.dart`

**Migration Steps**:
1. Add `boss_id` column to `users_table`
2. For existing apprentice accounts:
   - Option A: Set `bossId` to `null` (orphaned apprentices)
   - Option B: Try to match to a boss (if possible)
   - Option C: Mark for manual assignment

### 9.2 Firestore Migration
**Considerations**:
- Existing apprentice accounts in Firestore won't have `bossId`
- Decide on migration strategy:
  - Manual update via admin script
  - Leave as-is and only enforce for new accounts
  - Auto-assign to first boss found

---

## Phase 10: Testing Checklist

### 10.1 Signup Flow
- [ ] Boss can sign up successfully
- [ ] Apprentice signup is blocked/not available
- [ ] First setup screen only shows boss option

### 10.2 Apprentice Creation
- [ ] Boss can add apprentice from Manage Users
- [ ] Apprentice account is created with correct `bossId`
- [ ] Apprentice appears in boss's apprentice list
- [ ] Non-boss users cannot add apprentices

### 10.3 Login Flow
- [ ] Boss can log in normally
- [ ] Apprentice can log in if account exists
- [ ] Apprentice cannot sign up (no option available)

### 10.4 Data Integrity
- [ ] `bossId` is saved to local DB
- [ ] `bossId` is saved to Firestore
- [ ] Apprentice queries filter by `bossId`
- [ ] Sync handles `bossId` correctly

---

## Implementation Order

1. **Phase 1**: Database schema changes (foundation)
2. **Phase 2**: Data model updates
3. **Phase 5**: Repository & DAO updates
4. **Phase 3**: Authentication flow changes
5. **Phase 4**: UI changes
6. **Phase 6**: Sync updates
7. **Phase 7**: Validation & security
8. **Phase 8**: UI/UX improvements
9. **Phase 9**: Migration
10. **Phase 10**: Testing

---

## Files to Modify

### Core Files:
1. `lib/core/database/tables/users_table.dart` - Add bossId column
2. `lib/core/database/app_database.dart` - Migration
3. `lib/core/database/daos/users_dao.dart` - Update methods
4. `lib/data/models/app_user.dart` - Add bossId field
5. `lib/data/repositories/auth_repository.dart` - Update signup logic

### UI Files:
6. `lib/features/auth/view/first_setup_screen.dart` - Remove apprentice signup
7. `lib/features/auth/viewmodel/auth_viewmodel.dart` - Add createApprentice method
8. `lib/features/account/view/manage_users_screen.dart` - Update to "Add Apprentice"

### Sync Files:
9. `lib/core/sync/sync_orchestrator.dart` - Handle bossId in sync

---

## Notes

- **Backward Compatibility**: Existing apprentice accounts may not have `bossId`. Decide on handling strategy.
- **Multiple Bosses**: If multiple bosses can exist, ensure apprentices are properly linked.
- **Error Handling**: Add clear error messages when:
  - Non-boss tries to add apprentice
  - Apprentice tries to sign up
  - Invalid bossId provided

---

## Success Criteria

✅ Only bosses can sign up
✅ Apprentices can only be added by bosses
✅ Apprentices can only log in (not sign up)
✅ Every apprentice is linked to a boss via `bossId`
✅ UI clearly shows "Add Apprentice" instead of generic "Create User"
✅ All existing functionality still works

