import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';

class LowStockThresholdScreen extends StatefulWidget {
  const LowStockThresholdScreen({super.key});

  @override
  State<LowStockThresholdScreen> createState() =>
      _LowStockThresholdScreenState();
}

class _LowStockThresholdScreenState extends State<LowStockThresholdScreen> {
  int _threshold = 10;

  void _increment() {
    setState(() => _threshold += 1);
  }

  void _decrement() {
    if (_threshold > 1) {
      setState(() => _threshold -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
        title: const Text(
          'Low Stock Threshold',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          final horizontalPadding = isNarrow ? 16.0 : 24.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Set the minimum quantity at which a product is considered low stock. This helps you restock in time.',
                  textAlign: TextAlign.center,
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: JuselSpacing.s16,
                    vertical: JuselSpacing.s16,
                  ),
                  decoration: BoxDecoration(
                    color: JuselColors.card(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: JuselColors.border(context)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'THRESHOLD (UNITS)',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _CircleButton(icon: Icons.remove, onTap: _decrement),
                          Text(
                            '$_threshold',
                            style: JuselTextStyles.headlineLarge(context).copyWith(
                              color: JuselColors.primaryColor(context),
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          _CircleButton(icon: Icons.add, onTap: _increment),
                        ],
                      ),
                      const SizedBox(height: JuselSpacing.s12),
                      Text(
                        'Recommended: 5–20 units',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: JuselSpacing.s16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(JuselSpacing.s12),
                  decoration: BoxDecoration(
                    color: JuselColors.primaryColor(context).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: JuselColors.primaryColor(context).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: JuselColors.primaryColor(context),
                      ),
                      const SizedBox(width: JuselSpacing.s12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Products with stock below ',
                            style: JuselTextStyles.bodyMedium(context).copyWith(
                              color: JuselColors.foreground(context),
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: '$_threshold units ',
                                style: TextStyle(
                                  color: JuselColors.primaryColor(context),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    'will appear in the Low Stock list and trigger dashboard alerts.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      backgroundColor: JuselColors.primaryColor(context),
                      foregroundColor: JuselColors.primaryForeground,
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
          );
        },
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: JuselColors.muted(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: JuselColors.foreground(context), size: 24),
      ),
    );
  }
}
