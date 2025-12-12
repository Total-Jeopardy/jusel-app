import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';

class OfflineIndicator extends ConsumerWidget {
  final Widget child;

  const OfflineIndicator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return Stack(
      children: [
        child,
        connectivityAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (isOnline) {
            if (isOnline) return const SizedBox.shrink();

            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Material(
                  color: JuselColors.destructiveColor(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: JuselSpacing.s16,
                      vertical: JuselSpacing.s12,
                    ),
                    decoration: BoxDecoration(
                      color: JuselColors.destructiveColor(context),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: JuselSpacing.s8),
                        Expanded(
                          child: Text(
                            'You\'re offline. Changes will sync when connection is restored.',
                            style: JuselTextStyles.bodySmall(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

