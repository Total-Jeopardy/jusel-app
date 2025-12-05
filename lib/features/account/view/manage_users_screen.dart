import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/auth/view/reset_password_screen.dart';

final _usersProvider = FutureProvider.autoDispose<List<UsersTableData>>((
  ref,
) async {
  final db = ref.read(appDatabaseProvider);
  return db.usersDao.getAllUsers();
});

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  bool _creatingUser = false;
  String? _togglingUserId;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(_usersProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
        title: const Text(
          'Manage Users',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: usersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(JuselSpacing.s16),
              child: Text(
                'Failed to load users: $e',
                style: JuselTextStyles.bodyMedium.copyWith(
                  color: JuselColors.destructive,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (users) {
            final management = users.where((u) {
              final role = u.role.toLowerCase();
              return role == 'boss' || role == 'management';
            }).toList();
            final apprentices = users.where((u) {
              final role = u.role.toLowerCase();
              return !(role == 'boss' || role == 'management');
            }).toList();

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Section(
                        title: 'Management (${management.length})',
                        users: management,
                        togglingUserId: _togglingUserId,
                        onToggle: _toggleUserStatus,
                        onViewActivity: _showActivityPlaceholder,
                        onResetPassword: _navigateToReset,
                      ),
                      const SizedBox(height: JuselSpacing.s16),
                      _Section(
                        title: 'Apprentices (${apprentices.length})',
                        users: apprentices,
                        togglingUserId: _togglingUserId,
                        onToggle: _toggleUserStatus,
                        onViewActivity: _showActivityPlaceholder,
                        onResetPassword: _navigateToReset,
                      ),
                      if (users.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: JuselSpacing.s12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(JuselSpacing.s16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: JuselColors.border),
                            ),
                            child: Text(
                              'No users found.',
                              style: JuselTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: JuselColors.mutedForeground,
                              ),
                            ),
                          ),
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
                      icon: _creatingUser
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(
                        _creatingUser ? 'Adding…' : 'Add User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: _creatingUser ? null : _showAddUserSheet,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleUserStatus(UsersTableData user) async {
    if (_togglingUserId != null) return;
    setState(() {
      _togglingUserId = user.id;
    });
    try {
      final dao = ref.read(appDatabaseProvider).usersDao;
      final updated = user.copyWith(
        isActive: !user.isActive,
        updatedAt: Value(DateTime.now()),
      );
      await dao.updateUser(updated.toCompanion(true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(user.isActive ? 'User deactivated' : 'User activated'),
        ),
      );
      ref.invalidate(_usersProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user: $e'),
          backgroundColor: JuselColors.destructive,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _togglingUserId = null;
        });
      }
    }
  }

  Future<void> _showAddUserSheet() async {
    final newUser = await showModalBottomSheet<_NewUserData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _NewUserSheet(),
    );

    if (newUser == null) return;

    setState(() => _creatingUser = true);
    try {
      await _createUserWithoutSwitchingSession(newUser);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User added successfully')));
      ref.invalidate(_usersProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add user: $e'),
          backgroundColor: JuselColors.destructive,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _creatingUser = false);
      }
    }
  }

  Future<void> _createUserWithoutSwitchingSession(_NewUserData data) async {
    final primary = Firebase.app();
    FirebaseApp secondary;
    try {
      secondary = Firebase.app('user_creator');
    } catch (_) {
      secondary = await Firebase.initializeApp(
        name: 'user_creator',
        options: primary.options,
      );
    }

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondary);
    final secondaryFirestore = FirebaseFirestore.instanceFor(app: secondary);

    final cred = await secondaryAuth.createUserWithEmailAndPassword(
      email: data.email,
      password: data.password,
    );
    final uid = cred.user?.uid;
    if (uid == null) {
      throw Exception('Failed to create user account.');
    }

    final now = DateTime.now();
    await secondaryFirestore.collection('users').doc(uid).set({
      'email': data.email,
      'name': data.name,
      'phone': data.phone,
      'role': data.role,
      'isActive': true,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': null,
    });

    final dao = ref.read(appDatabaseProvider).usersDao;
    await dao.insertUser(
      UsersTableCompanion.insert(
        id: uid,
        name: data.name,
        phone: data.phone,
        email: data.email,
        role: data.role,
        isActive: const Value(true),
        createdAt: now,
      ),
    );

    await secondaryAuth.signOut();
    await secondary.delete();
  }

  void _showActivityPlaceholder(UsersTableData user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Activity for ${user.name} coming soon.')),
    );
  }

  void _navigateToReset(UsersTableData user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          name: user.name,
          role: user.role,
          phone: user.phone,
          email: user.email,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<UsersTableData> users;
  final String? togglingUserId;
  final void Function(UsersTableData) onToggle;
  final void Function(UsersTableData) onViewActivity;
  final void Function(UsersTableData) onResetPassword;

  const _Section({
    required this.title,
    required this.users,
    required this.togglingUserId,
    required this.onToggle,
    required this.onViewActivity,
    required this.onResetPassword,
  });

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
        ...users.map(
          (user) => Padding(
            padding: const EdgeInsets.only(bottom: JuselSpacing.s8),
            child: _UserCard(
              user: user,
              toggling: togglingUserId == user.id,
              onToggle: () => onToggle(user),
              onViewActivity: () => onViewActivity(user),
              onResetPassword: () => onResetPassword(user),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final UsersTableData user;
  final bool toggling;
  final VoidCallback onToggle;
  final VoidCallback onViewActivity;
  final VoidCallback onResetPassword;

  const _UserCard({
    required this.user,
    required this.toggling,
    required this.onToggle,
    required this.onViewActivity,
    required this.onResetPassword,
  });

  Color _statusColor() {
    return user.isActive ? const Color(0xFF16A34A) : JuselColors.destructive;
  }

  String _statusText() {
    return user.isActive ? 'Active' : 'Inactive';
  }

  @override
  Widget build(BuildContext context) {
    final isInactive = !user.isActive;
    final statusColor = _statusColor();
    final initials = _initials(user.name);

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
          _UserAvatar(initials: initials, dimmed: isInactive),
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
                    _RoleChip(
                      label: user.role.toUpperCase(),
                      dimmed: isInactive,
                    ),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s6),
                Row(
                  children: [
                    const Icon(
                      Icons.mail_outline,
                      size: 16,
                      color: JuselColors.mutedForeground,
                    ),
                    const SizedBox(width: JuselSpacing.s6),
                    Expanded(
                      child: Text(
                        user.email,
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: JuselColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: JuselColors.mutedForeground,
                    ),
                    const SizedBox(width: JuselSpacing.s6),
                    Expanded(
                      child: Text(
                        user.phone,
                        style: JuselTextStyles.bodySmall.copyWith(
                          color: JuselColors.mutedForeground,
                          fontWeight: FontWeight.w600,
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
          _UserActions(
            isInactive: isInactive,
            toggling: toggling,
            onResetPassword: onResetPassword,
            onViewActivity: onViewActivity,
            onToggleStatus: onToggle,
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }
}

class _UserActions extends StatelessWidget {
  final bool isInactive;
  final bool toggling;
  final VoidCallback onResetPassword;
  final VoidCallback onViewActivity;
  final VoidCallback onToggleStatus;

  const _UserActions({
    required this.isInactive,
    required this.toggling,
    required this.onResetPassword,
    required this.onViewActivity,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_UserAction>(
      padding: EdgeInsets.zero,
      tooltip: 'User actions',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (action) {
        switch (action) {
          case _UserAction.resetPassword:
            onResetPassword();
            break;
          case _UserAction.viewActivity:
            onViewActivity();
            break;
          case _UserAction.deactivate:
            onToggleStatus();
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
        child: toggling
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: JuselColors.mutedForeground,
                ),
              )
            : const Icon(Icons.more_horiz, color: JuselColors.mutedForeground),
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
  final String initials;
  final bool dimmed;
  const _UserAvatar({required this.initials, required this.dimmed});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: dimmed
          ? JuselColors.muted.withOpacity(0.7)
          : JuselColors.muted,
      child: Text(
        initials,
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

class _NewUserData {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String role;

  const _NewUserData({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
  });
}

class _NewUserSheet extends StatefulWidget {
  const _NewUserSheet();

  @override
  State<_NewUserSheet> createState() => _NewUserSheetState();
}

class _NewUserSheetState extends State<_NewUserSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'apprentice';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _valid =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().length >= 6;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: viewInsets + 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: JuselColors.mutedForeground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: JuselSpacing.s12),
          Text(
            'Add User',
            style: JuselTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: JuselSpacing.s12),
          _Field(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Jane Doe',
          ),
          const SizedBox(height: JuselSpacing.s8),
          _Field(
            controller: _phoneController,
            label: 'Phone',
            hint: '+1 234 567 890',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: JuselSpacing.s8),
          _Field(
            controller: _emailController,
            label: 'Email',
            hint: 'user@jusel.store',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: JuselSpacing.s8),
          _Field(
            controller: _passwordController,
            label: 'Temporary Password',
            hint: 'At least 6 characters',
            obscure: true,
          ),
          const SizedBox(height: JuselSpacing.s12),
          Text(
            'Role',
            style: JuselTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: JuselColors.mutedForeground,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  value: 'boss',
                  groupValue: _role,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Boss'),
                  onChanged: (value) {
                    if (value != null) setState(() => _role = value);
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  value: 'apprentice',
                  groupValue: _role,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Apprentice'),
                  onChanged: (value) {
                    if (value != null) setState(() => _role = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _valid
                  ? () {
                      Navigator.pop(
                        context,
                        _NewUserData(
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          role: _role,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create User',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: JuselTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.mutedForeground,
          ),
        ),
        const SizedBox(height: JuselSpacing.s6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: JuselSpacing.s12,
              vertical: JuselSpacing.s12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: JuselColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: JuselColors.border),
            ),
          ),
        ),
      ],
    );
  }
}

enum _UserAction { resetPassword, viewActivity, deactivate }
