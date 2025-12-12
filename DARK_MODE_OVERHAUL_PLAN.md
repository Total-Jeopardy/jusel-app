# Dark Mode Overhaul Plan - Complete Implementation Guide

## Overview
This plan details all changes needed to fix dark mode issues across the app, using the Boss Dashboard header and Quick Actions as the design reference for consistency.

---

## Reference Design (Boss Dashboard - What's Working)
- **Header**: Uses `JuselColors.foreground(context)`, `JuselColors.mutedForeground(context)`, theme-aware colors
- **Quick Actions**: Uses `JuselColors.card(context)` for backgrounds, `JuselColors.border(context)` for borders, theme-aware gradients
- **Design Pattern**: All cards use `JuselColors.card(context)` instead of hardcoded `Colors.white`

---

## Phase 1: Account Screen Fixes

### File: `lib/features/account/view/account_screen.dart`

#### 1.1 Fix Profile Header (Make Dynamic)
**Current Issue**: Hardcoded data ('Jane Boss', '+1 234 567 890', 'jane@jusel.store')

**Changes**:
- Line 58-63: Replace `_ProfileHeader` with dynamic data from `authViewModelProvider`
- Change `_ProfileHeader` to accept `AppUser?` instead of hardcoded strings
- Update to:
```dart
final user = ref.watch(authViewModelProvider).valueOrNull;
_ProfileHeader(
  name: user?.name ?? 'User',
  role: user?.role.toUpperCase() ?? 'USER',
  phone: user?.phone ?? '',
  email: user?.email ?? '',
),
```

#### 1.2 Fix Section List Container (White Cards)
**Current Issue**: Line 316 - `color: Colors.white` doesn't adapt to dark mode

**Changes**:
- Line 316: Replace `Colors.white` with `JuselColors.card(context)`
- Line 318: Replace `Color(0xFFE5E7EB)` with `JuselColors.border(context)`

**Before**:
```dart
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: const Color(0xFFE5E7EB)),
),
```

**After**:
```dart
decoration: BoxDecoration(
  color: JuselColors.card(context),
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: JuselColors.border(context)),
),
```

#### 1.3 Fix Icon Container Background
**Current Issue**: Line 427 - `Color(0xFFF5F7FB)` is hardcoded light color

**Changes**:
- Line 427: Replace `Color(0xFFF5F7FB)` with `JuselColors.muted(context)`

**Before**:
```dart
decoration: BoxDecoration(
  color: const Color(0xFFF5F7FB),
  borderRadius: BorderRadius.circular(10),
),
```

**After**:
```dart
decoration: BoxDecoration(
  color: JuselColors.muted(context),
  borderRadius: BorderRadius.circular(10),
),
```

#### 1.4 Fix Footer Buttons
**Current Issue**: Lines 487, 509 - Hardcoded `Colors.white` and `JuselColors.background(context)`

**Changes**:
- Line 487: Replace `backgroundColor: JuselColors.background(context)` with `backgroundColor: JuselColors.card(context)`
- Line 509: Replace `backgroundColor: Colors.white` with `backgroundColor: JuselColors.card(context)`
- Line 492: Replace hardcoded `Color(0xFF2D6BFF)` with `JuselColors.primaryColor(context)`

**Before**:
```dart
style: OutlinedButton.styleFrom(
  backgroundColor: Colors.white,
  ...
),
child: const Text(
  'Switch to Apprentice View',
  style: TextStyle(
    color: Color(0xFF2D6BFF),
    ...
  ),
),
```

**After**:
```dart
style: OutlinedButton.styleFrom(
  backgroundColor: JuselColors.card(context),
  ...
),
child: Text(
  'Switch to Apprentice View',
  style: TextStyle(
    color: JuselColors.primaryColor(context),
    ...
  ),
),
```

#### 1.5 Fix Divider Color
**Current Issue**: Line 56 - Hardcoded `Color(0xFFE5E7EB)`

**Changes**:
- Line 56: Replace `Color(0xFFE5E7EB)` with `JuselColors.border(context)`

---

## Phase 2: Dashboard Statistics Cards Fixes

### File: `lib/features/dashboard/view/boss_dashboard.dart`

#### 2.1 Fix Overview Item Cards
**Current Issue**: Line 496 - `background ?? Colors.white` defaults to white

**Changes**:
- Line 496: Replace `background ?? Colors.white` with `background ?? JuselColors.card(context)`
- Line 381: Replace hardcoded `Color(0xFFFFF1F2)` with theme-aware warning background
  - Use: `JuselColors.warningColor(context).withOpacity(0.12)` for background
  - Use: `JuselColors.warningColor(context)` for text colors

**Before**:
```dart
decoration: BoxDecoration(
  color: background ?? Colors.white,
  ...
),
```

**After**:
```dart
decoration: BoxDecoration(
  color: background ?? JuselColors.card(context),
  ...
),
```

**For Low Stock Card** (Line 381):
```dart
_OverviewItem(
  ...
  background: JuselColors.warningColor(context).withOpacity(0.12),
  valueColor: JuselColors.warningColor(context),
  titleColor: JuselColors.warningColor(context),
  iconColor: JuselColors.warningColor(context),
),
```

#### 2.2 Fix Trend Card
**Current Issue**: Line 695 - `Colors.white` hardcoded

**Changes**:
- Line 695: Replace `Colors.white` with `JuselColors.card(context)`

**Before**:
```dart
decoration: BoxDecoration(
  color: Colors.white,
  ...
),
```

**After**:
```dart
decoration: BoxDecoration(
  color: JuselColors.card(context),
  ...
),
```

#### 2.3 Fix Top Products Card
**Current Issue**: Lines 814, 852 - `Colors.white` hardcoded

**Changes**:
- Line 814: Replace `Colors.white` with `JuselColors.card(context)`
- Line 852: Replace `Colors.white` with `JuselColors.card(context)`

#### 2.4 Fix Alerts Card
**Current Issue**: 
- Line 598: `Colors.white` in empty state
- Line 631: Hardcoded `Color(0xFFFFF4D6)` and `Color(0xFFFDE68A)` for alert items

**Changes**:
- Line 598: Replace `Colors.white` with `JuselColors.card(context)`
- Line 631: Replace hardcoded colors with theme-aware warning colors:
  - Background: `JuselColors.warningColor(context).withOpacity(0.15)`
  - Border: `JuselColors.warningColor(context).withOpacity(0.3)`
  - Text: `JuselColors.warningColor(context)`

**Before**:
```dart
decoration: BoxDecoration(
  color: const Color(0xFFFFF4D6),
  borderRadius: BorderRadius.circular(14),
  border: Border.all(
    color: const Color(0xFFFDE68A),
  ),
),
```

**After**:
```dart
decoration: BoxDecoration(
  color: JuselColors.warningColor(context).withOpacity(0.15),
  borderRadius: BorderRadius.circular(14),
  border: Border.all(
    color: JuselColors.warningColor(context).withOpacity(0.3),
  ),
),
```

---

## Phase 3: Account Sub-Screens Review

### Files to Check and Fix:
1. `lib/features/account/view/edit_profile_screen.dart`
2. `lib/features/account/view/manage_users_screen.dart`
3. `lib/features/account/view/shop_settings_screen.dart`
4. `lib/features/account/view/low_stock_threshold_screen.dart`
5. `lib/features/account/view/notifications_settings_screen.dart`
6. `lib/features/account/view/app_theme_screen.dart`
7. `lib/features/account/view/sync_status_screen.dart`
8. `lib/features/account/view/about_jusel_screen.dart`

**Search Pattern**: Look for:
- `Colors.white`
- `const Color(0xFF...)` (hardcoded hex colors)
- `Color(0xFFE5E7EB)` (border color)
- `Color(0xFFF5F7FB)` (muted background)

**Replace With**:
- `Colors.white` → `JuselColors.card(context)`
- `Color(0xFFE5E7EB)` → `JuselColors.border(context)`
- `Color(0xFFF5F7FB)` → `JuselColors.muted(context)`
- Status colors → Use `JuselColors.successColor(context)`, `JuselColors.warningColor(context)`, etc.

---

## Phase 4: Consistency Checklist

### Design Pattern to Follow (From Boss Dashboard):

1. **Cards**:
   - Background: `JuselColors.card(context)`
   - Border: `JuselColors.border(context).withOpacity(0.9)` or `withValues(alpha: 0.9)`
   - Border width: `0.5` or `1.1` (match QuickActionCard)
   - Border radius: `14` or `16` (match existing)

2. **Text Colors**:
   - Primary text: `JuselColors.foreground(context)`
   - Secondary text: `JuselColors.mutedForeground(context)`
   - Use `JuselTextStyles.*(context)` methods

3. **Status Colors**:
   - Success: `JuselColors.successColor(context)`
   - Warning: `JuselColors.warningColor(context)`
   - Error: `JuselColors.destructiveColor(context)`
   - Backgrounds: Use `.withOpacity(0.12)` or `.withOpacity(0.15)`

4. **Icon Containers**:
   - Background: `JuselColors.muted(context)`
   - Icon color: `JuselColors.foreground(context)` or specific status color

5. **Buttons**:
   - Background: `JuselColors.card(context)` for outlined buttons
   - Border: `JuselColors.border(context)` or status color

---

## Execution Order

1. **Start with Account Screen** (Phase 1)
   - Fix profile header to be dynamic
   - Fix all white cards
   - Fix all hardcoded colors
   - Test in dark mode

2. **Fix Dashboard Statistics** (Phase 2)
   - Fix overview cards
   - Fix trend card
   - Fix top products card
   - Fix alerts card
   - Test in dark mode

3. **Review Account Sub-Screens** (Phase 3)
   - Search each file for hardcoded colors
   - Apply same patterns
   - Test each screen in dark mode

4. **Final Verification**
   - Switch between light/dark mode
   - Check all cards are visible
   - Check all text is readable
   - Ensure consistency with Boss Dashboard design

---

## Testing Checklist

After each phase, verify:
- [ ] Cards have proper background in dark mode (not white)
- [ ] Text is visible (not white on white)
- [ ] Borders are visible
- [ ] Icons are visible
- [ ] Status colors work in both themes
- [ ] Profile data is dynamic (not hardcoded)
- [ ] All screens match Boss Dashboard design language

---

## Notes

- Always use `context` parameter when calling `JuselColors.*(context)` methods
- Remove `const` keyword from widgets that use context-based colors
- Test on both light and dark themes
- Use the QuickActionCard component as reference for card styling
- Use the Boss Dashboard header as reference for text styling

