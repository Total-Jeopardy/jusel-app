import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jusel_app/core/utils/theme.dart';

/// Service for handling permissions with user-friendly dialogs
class PermissionService {
  /// Request permission for image source (camera or gallery)
  /// Shows a dialog explaining why permission is needed before requesting
  Future<bool> requestImagePermission(
    BuildContext context,
    ImageSource source,
  ) async {
    final isCamera = source == ImageSource.camera;

    final permissions = isCamera
        ? <Permission>[Permission.camera]
        // For gallery, try Photos (iOS/Android 13+) then Storage (older Android)
        : <Permission>[Permission.photos, Permission.storage];

    final permissionName = isCamera ? 'Camera' : 'Photos/Storage';
    final explanation = isCamera
        ? 'Jusel needs access to your camera to take photos of products.'
        : 'Jusel needs access to your photos to select product images.';

    // Show explanation once before attempting requests
    final shouldRequest = await _showPermissionRequestDialog(
      context,
      permissionName,
      explanation,
    );
    if (!shouldRequest) return false;

    var permanentlyDenied = false;

    for (final permission in permissions) {
      final status = await permission.status;

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        permanentlyDenied = true;
        continue; // Try the next candidate (gallery flow)
      }

      final requestStatus = await permission.request();

      if (requestStatus.isGranted || requestStatus.isLimited) {
        return true;
      }

      if (requestStatus.isPermanentlyDenied) {
        permanentlyDenied = true;
        continue;
      }
    }

    // If we got here, nothing was granted
    if (permanentlyDenied) {
      final shouldOpen = await _showPermissionDeniedDialog(
        context,
        permissionName,
        explanation,
      );
      if (shouldOpen) {
        await openAppSettings();
      }
    } else {
      _showRetrySnackBar(context, permissionName, source);
    }

    return false;
  }

  /// Show dialog explaining why permission is needed
  Future<bool> _showPermissionRequestDialog(
    BuildContext context,
    String permissionName,
    String explanation,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Allow $permissionName Access?'),
            content: Text(explanation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: JuselColors.primaryColor(context),
                  foregroundColor: JuselColors.primaryForeground,
                ),
                child: const Text('Allow'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show dialog when permission is permanently denied
  Future<bool> _showPermissionDeniedDialog(
    BuildContext context,
    String permissionName,
    String explanation,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$permissionName Permission Required'),
            content: Text(
              '$explanation\n\n'
              'Please enable $permissionName permission in your device settings to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: JuselColors.primaryColor(context),
                  foregroundColor: JuselColors.primaryForeground,
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Check if permission is granted (without requesting)
  Future<bool> hasImagePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;
      return status.isGranted || status.isLimited;
    } else {
      final photosStatus = await Permission.photos.status;
      if (photosStatus.isGranted || photosStatus.isLimited) return true;
      final storageStatus = await Permission.storage.status;
      return storageStatus.isGranted || storageStatus.isLimited;
    }
  }

  void _showRetrySnackBar(
    BuildContext context,
    String permissionName,
    ImageSource source,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permissionName permission is required to continue.'),
        backgroundColor: JuselColors.destructiveColor(context),
        action: SnackBarAction(
          label: 'Try Again',
          textColor: JuselColors.primaryForeground,
          onPressed: () async {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            await requestImagePermission(context, source);
          },
        ),
      ),
    );
  }
}

/// Provider for PermissionService
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});
