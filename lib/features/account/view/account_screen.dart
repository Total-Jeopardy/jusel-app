import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/ui/components/profile_avatar.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
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
import 'package:jusel_app/data/models/app_user.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jusel_app/features/auth/view/login_screen.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _loggingOut = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).valueOrNull;
    final isApprentice = user?.role == 'apprentice';
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          safePop(context, fallbackRoute: '/boss-dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: JuselColors.background(context),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
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
                Divider(height: 1, color: JuselColors.border(context)),
                const SizedBox(height: JuselSpacing.s16),
                _ProfileHeader(user: user),
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
                _BusinessSection(isApprentice: isApprentice),
                const SizedBox(height: JuselSpacing.s12),
                _SectionList(
                  title: 'App Settings',
                  children: [
                    _Tile(
                      icon: Icons.notifications_none_outlined,
                      label: 'Notifications',
                      trailing: Text(
                        'On',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: JuselColors.mutedForeground(context),
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
                              color: JuselColors.mutedForeground(context),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right,
                            color: JuselColors.mutedForeground(context),
                          ),
                        ],
                      ),
                      action: _TileAction.appTheme,
                    ),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s12),
                _SectionList(
                  title: 'System',
                  children: [
                    _Tile(
                      icon: Icons.sync_outlined,
                      label: 'Sync Status',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: JuselColors.successColor(context),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: JuselColors.successColor(context),
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
                        color: JuselColors.mutedForeground(context),
                      ),
                      action: _TileAction.aboutJusel,
                    ),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s16),
                _FooterButtons(
                  onLogout: _handleLogout,
                  loggingOut: _loggingOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _loggingOut = true);
    try {
      await ref.read(authViewModelProvider.notifier).signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }
}

class _ProfileHeader extends ConsumerWidget {
  final AppUser? user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user?.name ?? 'User';
    final role = user?.role.toUpperCase() ?? 'USER';
    final phone = user?.phone ?? '';
    final email = user?.email ?? '';

    return Column(
      children: [
        ProfileAvatar(radius: 45, userId: user?.uid, userName: name),
        const SizedBox(height: JuselSpacing.s12),
        Text(
          name,
          style: JuselTextStyles.headlineSmall(
            context,
          ).copyWith(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        const SizedBox(height: JuselSpacing.s6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: JuselColors.primaryColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role,
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.background(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: JuselSpacing.s8),
            Text(
              phone,
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: JuselSpacing.s6),
        Text(
          email,
          style: JuselTextStyles.bodySmall(context).copyWith(
            color: JuselColors.mutedForeground(context),
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
          style: JuselTextStyles.bodySmall(context).copyWith(
            color: JuselColors.mutedForeground(context),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        Container(
          decoration: BoxDecoration(
            color: JuselColors.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JuselColors.border(context)),
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

class _BusinessSection extends StatelessWidget {
  final bool isApprentice;
  const _BusinessSection({required this.isApprentice});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (!isApprentice) {
      items.addAll(const [
        _Tile(
          icon: Icons.group_outlined,
          label: 'Manage Users',
          action: _TileAction.manageUsers,
        ),
      ]);
    }

    items.add(
      const _Tile(
        icon: Icons.store_mall_directory_outlined,
        label: 'Shop Settings',
        action: _TileAction.shopSettings,
      ),
    );

    if (!isApprentice) {
      items.add(
        _Tile(
          icon: Icons.warning_amber_outlined,
          label: 'Low Stock Threshold',
          trailing: Text(
            '< 10 units',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: JuselColors.mutedForeground(context),
            ),
          ),
          action: _TileAction.lowStockThreshold,
        ),
      );
    }

    return _SectionList(title: 'Business', children: items);
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
                color: JuselColors.muted(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: JuselColors.foreground(context)),
            ),
            const SizedBox(width: JuselSpacing.s12),
            Expanded(
              child: Text(
                label,
                style: JuselTextStyles.bodyMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: JuselColors.mutedForeground(context),
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

class _FooterButtons extends ConsumerWidget {
  final VoidCallback onLogout;
  final bool loggingOut;

  const _FooterButtons({required this.onLogout, required this.loggingOut});

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return '${lastSync.day}/${lastSync.month}/${lastSync.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              context.go('/apprentice-dashboard');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: JuselColors.muted(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s12),
              backgroundColor: JuselColors.card(context),
            ),
            child: Text(
              'Switch to Apprentice View',
              style: TextStyle(
                color: JuselColors.primaryColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: loggingOut ? null : onLogout,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: JuselColors.destructiveColor(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s12),
              backgroundColor: JuselColors.card(context),
            ),
            child: loggingOut
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        JuselColors.destructiveColor(context),
                      ),
                    ),
                  )
                : Text(
                    'Log Out',
                    style: TextStyle(
                      color: JuselColors.destructiveColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: JuselSpacing.s12),
        FutureBuilder(
          future: ref.read(settingsServiceProvider.future),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text(
                'Version 0.1.0\nLast Synced: Loading...',
                textAlign: TextAlign.center,
                style: JuselTextStyles.bodySmall(
                  context,
                ).copyWith(color: JuselColors.mutedForeground(context)),
              );
            }

            final settingsService = snapshot.data!;
            return FutureBuilder<DateTime?>(
              future: settingsService.getLastSyncedAt(),
              builder: (context, syncSnapshot) {
                final lastSync = syncSnapshot.data;
                final syncText = _formatLastSync(lastSync);

                return Text(
                  'Version 0.1.0\nLast Synced: $syncText',
                  textAlign: TextAlign.center,
                  style: JuselTextStyles.bodySmall(
                    context,
                  ).copyWith(color: JuselColors.mutedForeground(context)),
                );
              },
            );
          },
        ),
        const SizedBox(height: JuselSpacing.s16),
      ],
    );
  }
}
