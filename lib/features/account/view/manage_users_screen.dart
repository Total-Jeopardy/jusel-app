import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/auth/view/reset_password_screen.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final managementUsers = [
      _User(
        name: 'Jane Boss',
        email: 'jane@jusel.store',
        phone: '+1 234 567 890',
        role: 'BOSS',
        status: _UserStatus.active,
        avatarAsset: 'assets/avatar_placeholder.png',
      ),
    ];

    final apprenticeUsers = [
      _User(
        name: 'John Doe',
        phone: '+1 555 012 3456',
        role: 'STAFF',
        status: _UserStatus.active,
        initials: 'JD',
      ),
      _User(
        name: 'Sarah Smith',
        email: 'sarah.s@jusel.store',
        role: 'STAFF',
        status: _UserStatus.active,
        avatarAsset: 'assets/avatar_placeholder.png',
      ),
      _User(
        name: 'Kyle Thomas',
        role: 'STAFF',
        status: _UserStatus.inactive,
        initials: 'KT',
        phone: null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Users',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          final horizontalPadding = isNarrow ? 16.0 : 24.0;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  90,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: 'Management (${managementUsers.length})',
                      users: managementUsers,
                    ),
                    const SizedBox(height: JuselSpacing.s16),
                    _Section(
                      title: 'Apprentices (${apprenticeUsers.length})',
                      users: apprenticeUsers,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JuselColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: JuselSpacing.s16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      shadowColor: JuselColors.primary.withOpacity(0.35),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add User',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_User> users;

  const _Section({required this.title, required this.users});

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
            fontSize: 13,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        ...users
            .map(
              (user) => Padding(
                padding: const EdgeInsets.only(bottom: JuselSpacing.s8),
                child: _UserCard(user: user),
              ),
            )
            .toList(),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final _User user;
  const _UserCard({required this.user});

  Color _statusColor() {
    return user.status == _UserStatus.active
        ? const Color(0xFF16A34A)
        : JuselColors.destructive;
  }

  String _statusText() {
    return user.status == _UserStatus.active ? 'Active' : 'Inactive';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final isInactive = user.status == _UserStatus.inactive;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JuselColors.border),
      ),
      padding: const EdgeInsets.all(JuselSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserAvatar(user: user, dimmed: isInactive),
          const SizedBox(width: JuselSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: JuselTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isInactive
                              ? JuselColors.mutedForeground
                              : JuselColors.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: JuselSpacing.s6),
                    _RoleChip(label: user.role, dimmed: isInactive),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s6),
                if (user.email != null)
                  Row(
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 16,
                        color: isInactive
                            ? JuselColors.mutedForeground
                            : JuselColors.mutedForeground,
                      ),
                      const SizedBox(width: JuselSpacing.s6),
                      Expanded(
                        child: Text(
                          user.email!,
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: isInactive
                                ? JuselColors.mutedForeground
                                : JuselColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (user.email != null) const SizedBox(height: JuselSpacing.s4),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: isInactive
                          ? JuselColors.mutedForeground
                          : JuselColors.mutedForeground,
                    ),
                    const SizedBox(width: JuselSpacing.s6),
                    Expanded(
                      child: Text(
                        user.phone ?? 'No phone added',
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: isInactive
                              ? JuselColors.mutedForeground
                              : JuselColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                          fontStyle: user.phone == null
                              ? FontStyle.italic
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s6),
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: statusColor),
                    const SizedBox(width: JuselSpacing.s6),
                    Text(
                      _statusText(),
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: JuselSpacing.s6),
          _UserActions(user: user, isInactive: isInactive),
        ],
      ),
    );
  }
}

class _UserActions extends StatelessWidget {
  final _User user;
  final bool isInactive;
  const _UserActions({required this.user, required this.isInactive});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_UserAction>(
      padding: EdgeInsets.zero,
      tooltip: 'User actions',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (action) {
        switch (action) {
          case _UserAction.resetPassword:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(
                  name: user.name,
                  role: user.role,
                  phone: user.phone,
                  email: user.email,
                  avatarAsset: user.avatarAsset,
                  initials: user.initials,
                ),
              ),
            );
            break;
          case _UserAction.viewActivity:
            // TODO: Hook up view activity screen when available.
            break;
          case _UserAction.deactivate:
            // TODO: Hook up activate/deactivate user flow.
            break;
        }
      },
      itemBuilder: (context) => [
        _menuItem(
          value: _UserAction.resetPassword,
          label: 'Reset Password',
          icon: Icons.lock_reset_outlined,
        ),
        _menuItem(
          value: _UserAction.viewActivity,
          label: 'View Activity',
          icon: Icons.show_chart_outlined,
        ),
        _menuItem(
          value: _UserAction.deactivate,
          label: isInactive ? 'Activate User' : 'Deactivate User',
          icon: isInactive ? Icons.check_circle_outline : Icons.block,
          isDestructive: !isInactive,
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: JuselColors.muted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.more_horiz, color: JuselColors.mutedForeground),
      ),
    );
  }

  PopupMenuItem<_UserAction> _menuItem({
    required _UserAction value,
    required String label,
    required IconData icon,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<_UserAction>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive
                ? JuselColors.destructive
                : JuselColors.foreground,
          ),
          const SizedBox(width: JuselSpacing.s8),
          Text(
            label,
            style: TextStyle(
              color: isDestructive
                  ? JuselColors.destructive
                  : JuselColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final _User user;
  final bool dimmed;
  const _UserAvatar({required this.user, required this.dimmed});

  @override
  Widget build(BuildContext context) {
    if (user.avatarAsset != null) {
      return CircleAvatar(
        radius: 26,
        backgroundImage: AssetImage(user.avatarAsset!),
        foregroundColor: dimmed ? JuselColors.mutedForeground : null,
      );
    }

    return CircleAvatar(
      radius: 26,
      backgroundColor: dimmed
          ? JuselColors.muted.withOpacity(0.7)
          : JuselColors.muted,
      child: Text(
        user.initials ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: JuselColors.mutedForeground,
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool dimmed;
  const _RoleChip({required this.label, required this.dimmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dimmed
            ? JuselColors.muted.withOpacity(0.9)
            : const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: dimmed ? JuselColors.mutedForeground : JuselColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

enum _UserStatus { active, inactive }

class _User {
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final _UserStatus status;
  final String? avatarAsset;
  final String? initials;

  _User({
    required this.name,
    required this.role,
    required this.status,
    this.email,
    this.phone,
    this.avatarAsset,
    this.initials,
  });
}

enum _UserAction { resetPassword, viewActivity, deactivate }
