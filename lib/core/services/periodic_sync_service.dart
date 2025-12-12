import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/sync/sync_orchestrator.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

/// Service that handles periodic automatic syncing
/// 
/// Features:
/// - Idempotent: safe to call start() multiple times
/// - Role-based: apprentices sync every 30s (mandatory), bosses every 60s (optional)
/// - Auto-stops on logout or when auto sync is disabled
/// - Backoff on errors to avoid battery/data drain
class PeriodicSyncService {
  final Ref _ref;
  Timer? _syncTimer;
  bool _isRunning = false;
  int _consecutiveFailures = 0;
  static const int _maxBackoffMultiplier = 4; // Max 4x delay on repeated failures

  PeriodicSyncService(this._ref);

  /// Start periodic syncing (idempotent - safe to call multiple times)
  /// For apprentices: sync every 30 seconds (mandatory)
  /// For bosses: sync every 60 seconds if auto sync is enabled
  Future<void> start() async {
    // Always stop first to ensure no overlapping timers
    stop();

    final user = _ref.read(authViewModelProvider).value;
    if (user == null) {
      return; // No user logged in, don't start
    }

    final isApprentice = user.role == 'apprentice';

    // For apprentices, sync is always mandatory
    if (isApprentice) {
      _startPeriodicSync(const Duration(seconds: 30));
      return;
    }

    // For bosses, check auto sync setting
    try {
      final settingsService = await _ref.read(settingsServiceProvider.future);
      final autoSync = await settingsService.getAutoSync();

      if (autoSync) {
        _startPeriodicSync(const Duration(seconds: 60));
      } else {
        // Boss has auto sync disabled, ensure we're stopped
        stop();
      }
    } catch (e) {
      // If we can't read settings, don't start sync
      print('[PeriodicSync] Failed to read settings: $e');
      stop();
    }
  }

  void _startPeriodicSync(Duration baseInterval) {
    // Cancel any existing timer first (idempotent)
    _syncTimer?.cancel();
    _isRunning = true;
    _consecutiveFailures = 0; // Reset failure count on successful start
    
    // Calculate interval with backoff (if there were previous failures)
    final interval = _calculateInterval(baseInterval);
    
    // Run first sync immediately (but with a small delay to avoid blocking)
    Future.microtask(() {
      _performSync();
    });

    // Then run periodically
    _syncTimer = Timer.periodic(interval, (_) {
      _performSync();
    });
  }

  /// Calculate sync interval with exponential backoff on failures
  Duration _calculateInterval(Duration baseInterval) {
    if (_consecutiveFailures == 0) {
      return baseInterval;
    }
    
    // Exponential backoff: 2x, 3x, 4x the base interval
    final multiplier = (_consecutiveFailures + 1).clamp(2, _maxBackoffMultiplier);
    return Duration(
      seconds: (baseInterval.inSeconds * multiplier).clamp(
        baseInterval.inSeconds,
        baseInterval.inSeconds * _maxBackoffMultiplier,
      ),
    );
  }

  Future<void> _performSync() async {
    // Check user is still logged in
    final user = _ref.read(authViewModelProvider).value;
    if (user == null) {
      // User logged out, stop syncing
      stop();
      return;
    }

    // Verify role hasn't changed (apprentice should always sync)
    final isApprentice = user.role == 'apprentice';
    
    // For bosses, check if auto sync is still enabled
    if (!isApprentice) {
      try {
        final settingsService = await _ref.read(settingsServiceProvider.future);
        final autoSync = await settingsService.getAutoSync();
        if (!autoSync) {
          // Auto sync was disabled, stop
          stop();
          return;
        }
      } catch (e) {
        // If we can't read settings, skip this cycle
        print('[PeriodicSync] Failed to read settings: $e');
        return;
      }
    }

    try {
      final orchestrator = _ref.read(syncOrchestratorProvider);
      
      // Check if online
      if (!await orchestrator.isOnline()) {
        _consecutiveFailures++;
        return; // Skip sync when offline, but don't reset failure count
      }

      // Pull down data first
      final pullResult = await orchestrator.pullAllForUser(user.uid);
      
      // Then push local changes
      final pushResult = await orchestrator.syncAll();

      // Only update last synced timestamp if BOTH operations succeeded
      final bothSucceeded = pullResult.status != SyncStatus.error &&
          pullResult.status != SyncStatus.offline &&
          pushResult.status != SyncStatus.error &&
          pushResult.status != SyncStatus.offline;

      if (bothSucceeded) {
        // Reset failure count on success
        _consecutiveFailures = 0;
        
        // Update last synced timestamp
        try {
          final settingsService = await _ref.read(settingsServiceProvider.future);
          await settingsService.setLastSyncedAt(DateTime.now());
        } catch (e) {
          // Log but don't fail the sync
          print('[PeriodicSync] Failed to update last synced timestamp: $e');
        }
      } else {
        // One or both operations failed
        _consecutiveFailures++;
        
        // If we've had many failures, increase the interval
        if (_consecutiveFailures > 0 && _isRunning) {
          final user = _ref.read(authViewModelProvider).value;
          if (user != null) {
            final isApprentice = user.role == 'apprentice';
            final baseInterval = isApprentice 
                ? const Duration(seconds: 30)
                : const Duration(seconds: 60);
            
            // Restart with new interval (backoff)
            _syncTimer?.cancel();
            _startPeriodicSync(baseInterval);
          }
        }
      }
    } catch (e) {
      // Increment failure count on exception
      _consecutiveFailures++;
      print('[PeriodicSync] Error during sync: $e');
      
      // If too many failures, stop to avoid battery drain
      if (_consecutiveFailures >= 10) {
        print('[PeriodicSync] Too many failures, stopping periodic sync');
        stop();
      }
    }
  }

  /// Stop periodic syncing (idempotent - safe to call multiple times)
  void stop() {
    if (!_isRunning && _syncTimer == null) {
      return; // Already stopped
    }
    
    _syncTimer?.cancel();
    _syncTimer = null;
    _isRunning = false;
    _consecutiveFailures = 0; // Reset failure count when stopped
  }

  /// Restart with new settings (called when auto sync setting changes or user logs in)
  /// This is idempotent - always stops first, then starts
  Future<void> restart() async {
    stop();
    await start();
  }

  void dispose() {
    stop();
  }
}

/// Provider for PeriodicSyncService
/// 
/// Auto-starts when provider is first accessed (after user is logged in)
/// Auto-stops when provider is disposed
final periodicSyncServiceProvider = Provider<PeriodicSyncService>((ref) {
  final service = PeriodicSyncService(ref);
  
  // Listen to auth state changes to stop sync on logout
  ref.listen<AsyncValue>(authViewModelProvider, (previous, next) {
    final previousUser = previous?.valueOrNull;
    final nextUser = next.valueOrNull;
    
    // If user logged out, stop sync
    if (previousUser != null && nextUser == null) {
      service.stop();
    }
    // If user logged in, start sync
    else if (previousUser == null && nextUser != null) {
      service.start();
    }
    // If user changed (different user), restart sync
    else if (previousUser != null && nextUser != null && previousUser.uid != nextUser.uid) {
      service.restart();
    }
  });
  
  // Auto-start when provider is created (only if user is already logged in)
  Future.microtask(() {
    final user = ref.read(authViewModelProvider).value;
    if (user != null) {
      service.start();
    }
  });
  
  // Clean up when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
