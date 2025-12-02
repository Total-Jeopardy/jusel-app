import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

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
          'Sync Status',
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
                  20,
                  horizontalPadding,
                  28,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: JuselSpacing.s12),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE7F6EF),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cloud_done_rounded,
                        color: Color(0xFF16A34A),
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    Text(
                      'All Synced',
                      style: JuselTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s4),
                    Text(
                      'Your data is safely backed up to the cloud.',
                      textAlign: TextAlign.center,
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s40),
                    _StatusCard(),
                    const SizedBox(height: JuselSpacing.s16),
                    _InfoBanner(),
                    const SizedBox(height: JuselSpacing.s20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: JuselColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Sync Now',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'View Pending Items',
                          style: TextStyle(
                            color: JuselColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
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

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusRow(label: 'Last Successful Sync', value: 'Today, 10:42 AM'),
          Divider(height: 1, color: Color(0xFFE5E7EB)),
          _StatusRow(label: 'Pending Operations', value: '0 items'),
          Divider(height: 1, color: Color(0xFFE5E7EB)),
          _StatusRow(
            label: 'Connection Status',
            value: 'Online',
            valueColor: Color(0xFF16A34A),
            showDot: true,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool showDot;

  const _StatusRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: JuselTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: JuselColors.foreground,
                fontSize: 16,
              ),
            ),
          ),
          if (showDot) ...[
            const Icon(Icons.circle, size: 10, color: Color(0xFF16A34A)),
            const SizedBox(width: JuselSpacing.s6),
          ],
          Text(
            value,
            style: JuselTextStyles.bodySmall.copyWith(
              color: valueColor ?? JuselColors.mutedForeground,
              fontWeight: FontWeight.w400,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.wifi_off_outlined,
                color: JuselColors.mutedForeground,
              ),
            ),
            const SizedBox(width: JuselSpacing.s12),
            Expanded(
              child: Text(
                'Jusel is designed to work offline. Changes made without internet are saved locally and automatically synced when connection is restored.',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
