import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/account/view/change_password_placeholder.dart';
import 'package:jusel_app/features/account/view/edit_profile_screen.dart';
import 'package:jusel_app/features/account/view/manage_users_screen.dart';
import 'package:jusel_app/features/account/view/shop_settings_screen.dart';
import 'package:jusel_app/features/account/view/low_stock_threshold_screen.dart';
import 'package:jusel_app/features/account/view/notifications_settings_screen.dart';
import 'package:jusel_app/features/account/view/app_theme_screen.dart';
import 'package:jusel_app/features/account/view/sync_status_screen.dart';
import 'package:jusel_app/features/account/view/about_jusel_screen.dart';
import 'package:jusel_app/features/dashboard/view/apprentice_dashboard.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: JuselSpacing.s16),
              const _ProfileHeader(
                name: 'Jane Boss',
                role: 'BOSS',
                phone: '+1 234 567 890',
                email: 'jane@jusel.store',
              ),
              const SizedBox(height: JuselSpacing.s16),
              const _SectionList(
                title: 'Account',
                children: [
                  _Tile(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profile',
                    action: _TileAction.editProfile,
                  ),
                  _Tile(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    action: _TileAction.changePassword,
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s16),
              const _SectionList(
                title: 'Business',
                children: [
                  _Tile(
                    icon: Icons.group_outlined,
                    label: 'Manage Users',
                    action: _TileAction.manageUsers,
                  ),

                  _Tile(
                    icon: Icons.store_mall_directory_outlined,
                    label: 'Shop Settings',
                    action: _TileAction.shopSettings,
                  ),
                  _Tile(
                    icon: Icons.warning_amber_outlined,
                    label: 'Low Stock Threshold',
                    trailing: Text(
                      '< 10 units',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.mutedForeground,
                      ),
                    ),
                    action: _TileAction.lowStockThreshold,
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s12),
              const _SectionList(
                title: 'App Settings',
                children: [
                  _Tile(
                    icon: Icons.notifications_none_outlined,
                    label: 'Notifications',
                    trailing: Text(
                      'On',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.mutedForeground,
                      ),
                    ),
                    action: _TileAction.notifications,
                  ),
                  _Tile(
                    icon: Icons.dark_mode_outlined,
                    label: 'App Theme',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Light',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: JuselColors.mutedForeground,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right,
                          color: JuselColors.mutedForeground,
                        ),
                      ],
                    ),
                    action: _TileAction.appTheme,
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s12),
              const _SectionList(
                title: 'System',
                children: [
                  _Tile(
                    icon: Icons.sync_outlined,
                    label: 'Sync Status',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 10, color: Color(0xFF16A34A)),
                        SizedBox(width: 6),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    action: _TileAction.syncStatus,
                  ),
                  _Tile(
                    icon: Icons.info_outline,
                    label: 'About Jusel',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: JuselColors.mutedForeground,
                    ),
                    action: _TileAction.aboutJusel,
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s16),
              _FooterButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final String phone;
  final String email;

  const _ProfileHeader({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 45,
          backgroundImage: AssetImage('assets/avatar_placeholder.png'),
        ),
        const SizedBox(height: JuselSpacing.s12),
        Text(
          name,
          style: JuselTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: JuselSpacing.s6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: JuselColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role,
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.background,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: JuselSpacing.s8),
            Text(
              phone,
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: JuselSpacing.s6),
        Text(
          email,
          style: JuselTextStyles.bodySmall.copyWith(
            color: JuselColors.mutedForeground,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _SectionList extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionList({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: JuselTextStyles.bodySmall.copyWith(
            color: JuselColors.mutedForeground,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: JuselSpacing.s12,
            vertical: JuselSpacing.s4,
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    const Divider(
                      height: 1,
                      color: Color(0xFFE5E7EB),
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

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final _TileAction? action;
  const _Tile({
    required this.icon,
    required this.label,
    this.trailing,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        switch (action) {
          case _TileAction.editProfile:
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
            break;
          case _TileAction.changePassword:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ChangePasswordPlaceholderScreen(),
              ),
            );
            break;
          case _TileAction.manageUsers:
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
            );
            break;
          case _TileAction.shopSettings:
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShopSettingsScreen()),
            );
            break;
          case _TileAction.lowStockThreshold:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LowStockThresholdScreen(),
              ),
            );
            break;
          case _TileAction.notifications:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsSettingsScreen(),
              ),
            );
            break;
          case _TileAction.appTheme:
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AppThemeScreen()));
            break;
          case _TileAction.syncStatus:
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SyncStatusScreen()));
            break;
          case _TileAction.aboutJusel:
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AboutJuselScreen()));
            break;
          default:
            break;
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: JuselColors.foreground),
            ),
            const SizedBox(width: JuselSpacing.s12),
            Expanded(
              child: Text(
                label,
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: JuselColors.mutedForeground,
                ),
          ],
        ),
      ),
    );
  }
}

enum _TileAction {
  editProfile,
  changePassword,
  manageUsers,
  shopSettings,
  lowStockThreshold,
  notifications,
  appTheme,
  syncStatus,
  aboutJusel,
}

class _FooterButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              context.go('/apprentice-dashboard');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: JuselColors.muted),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s12),
              backgroundColor: JuselColors.background,
            ),
            child: const Text(
              'Switch to Apprentice View',
              style: TextStyle(
                color: Color(0xFF2D6BFF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // TODO: logout
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: JuselColors.destructive),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s12),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: JuselColors.destructive,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: JuselSpacing.s12),
        Text(
          'Version 1.2.0 (Build 45)\nLast Synced: Just now',
          textAlign: TextAlign.center,
          style: JuselTextStyles.bodySmall.copyWith(
            color: JuselColors.mutedForeground,
          ),
        ),
        const SizedBox(height: JuselSpacing.s16),
      ],
    );
  }
}
