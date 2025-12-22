import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';

/// A reusable widget that displays a user's profile image with fallback to initials
class ProfileAvatar extends ConsumerWidget {
  final double radius;
  final String? userId;
  final String? userName;
  final String? imageUrl; // Optional override URL (can be network URL or local file path)
  final Color? backgroundColor;

  const ProfileAvatar({
    super.key,
    this.radius = 25,
    this.userId,
    this.userName,
    this.imageUrl,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: imageUrl == null ? _getImageUrl(ref) : Future.value(null),
      builder: (context, snapshot) {
        final url = imageUrl ?? snapshot.data;
        final hasImage = url != null && url.isNotEmpty;
        final isLocalFile = hasImage && url.startsWith('/');

        if (hasImage) {
          if (isLocalFile) {
            // Local file path
            return CircleAvatar(
              radius: radius,
              backgroundColor: backgroundColor ?? JuselColors.muted(context),
              backgroundImage: FileImage(File(url)),
              onBackgroundImageError: (_, __) {
                // If image fails to load, show initials
              },
              child: _buildInitials(context),
            );
          } else {
            // Network URL
            return CircleAvatar(
              radius: radius,
              backgroundColor: backgroundColor ?? JuselColors.muted(context),
              backgroundImage: NetworkImage(url),
              onBackgroundImageError: (_, __) {
                // If image fails to load, show initials
              },
              child: _buildInitials(context),
            );
          }
        }

        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? JuselColors.muted(context),
          child: _buildInitials(context),
        );
      },
    );
  }

  Future<String?> _getImageUrl(WidgetRef ref) async {
    if (userId == null) return null;
    try {
      final settingsService = await ref.read(settingsServiceProvider.future);
      return await settingsService.getProfileImageUrl();
    } catch (e) {
      return null;
    }
  }

  Widget _buildInitials(BuildContext context) {
    if (userName == null || userName!.isEmpty) {
      return Icon(
        Icons.person,
        size: radius,
        color: JuselColors.mutedForeground(context),
      );
    }

    final initials = _extractInitials(userName!);
    return Text(
      initials,
      style: TextStyle(
        fontSize: radius * 0.6,
        fontWeight: FontWeight.w800,
        color: JuselColors.foreground(context),
      ),
    );
  }

  String _extractInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    if (trimmed.length == 1) return trimmed.toUpperCase();
    
    final parts = trimmed.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return trimmed.length >= 2
        ? trimmed.substring(0, 2).toUpperCase()
        : trimmed.substring(0, 1).toUpperCase();
  }
}

