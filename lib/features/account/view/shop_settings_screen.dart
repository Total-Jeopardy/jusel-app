import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class ShopSettingsScreen extends StatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  State<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends State<ShopSettingsScreen> {
  bool _autoSync = true;
  String _lastSynced = 'Just now';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shop Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          final horizontalPadding = isNarrow ? 16.0 : 24.0;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: JuselSpacing.s12),
                    const _ShopLogo(),
                    const SizedBox(height: JuselSpacing.s12),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Edit Shop Logo',
                        style: TextStyle(
                          color: JuselColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _SettingsSection(
                      title: 'GENERAL INFO',
                      children: [
                        const _SettingTile(
                          label: 'Shop Name *',
                          value: 'Jusel Store',
                        ),
                        const _SettingTile(
                          label: 'Phone',
                          value: '+233 55 123 4567',
                        ),
                        _SettingTile(
                          label: 'Address',
                          value: 'Add address (Optional)',
                          valueStyle: JuselTextStyles.bodySmall.copyWith(
                            color: JuselColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const _SettingTile(
                          label: 'Currency',
                          value: 'GHS (Ghana Cedi)',
                          trailing: Icon(
                            Icons.chevron_right,
                            color: JuselColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _SettingsSection(
                      title: 'DATA & SYNC',
                      children: [
                        _ToggleTile(
                          label: 'Auto Sync',
                          value: _autoSync,
                          onChanged: (val) => setState(() => _autoSync = val),
                        ),
                        _SyncTile(
                          lastSynced: _lastSynced,
                          onSyncNow: () {
                            setState(() => _lastSynced = 'Just now');
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: JuselSpacing.s12,
                            vertical: JuselSpacing.s12,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enable auto sync to backup data whenever you are online.',
                              style: JuselTextStyles.bodySmall.copyWith(
                                color: JuselColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _SettingsSection(
                      title: 'INVENTORY',
                      children: [
                        _NavigationTile(
                          icon: Icons.widgets_outlined,
                          label: 'Low Stock Threshold',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: JuselColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShopLogo extends StatelessWidget {
  const _ShopLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        color: JuselColors.muted,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const CircleAvatar(
        radius: 46,
        backgroundImage: AssetImage('assets/avatar_placeholder.png'),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: JuselColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: JuselTextStyles.bodySmall.copyWith(
              color: JuselColors.mutedForeground,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: JuselSpacing.s8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Widget? trailing;

  const _SettingTile({
    required this.label,
    required this.value,
    this.valueStyle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  value,
                  style:
                      valueStyle ??
                      JuselTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground,
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: JuselTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: JuselColors.foreground,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: JuselColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SyncTile extends StatelessWidget {
  final String lastSynced;
  final VoidCallback onSyncNow;

  const _SyncTile({required this.lastSynced, required this.onSyncNow});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: onSyncNow,
            child: const Text(
              'Sync Now',
              style: TextStyle(
                color: JuselColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: JuselSpacing.s8),
          Expanded(
            child: Text(
              'Last synced: $lastSynced',
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.refresh,
            size: 18,
            color: JuselColors.mutedForeground,
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(0),
      child: InkWell(
        borderRadius: BorderRadius.circular(0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: JuselSpacing.s12,
            vertical: JuselSpacing.s12,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
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
              const Icon(
                Icons.chevron_right,
                color: JuselColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
