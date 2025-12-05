import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Safely pop a route if possible; otherwise, optionally navigate to a fallback route.
void safePop(BuildContext context, {String? fallbackRoute}) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
    return;
  }

  if (fallbackRoute != null) {
    context.go(fallbackRoute);
  }
}
