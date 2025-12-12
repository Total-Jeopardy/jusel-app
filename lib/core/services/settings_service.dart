import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Keys
  static const String _lowStockThresholdKey = 'low_stock_threshold';
  static const String _autoSyncKey = 'auto_sync';
  static const String _shopLogoUrlKey = 'shop_logo_url';
  static const String _newSalesAlertsKey = 'new_sales_alerts';
  static const String _lowStockAlertsKey = 'low_stock_alerts';
  static const String _syncStatusAlertsKey = 'sync_status_alerts';
  static const String _priceChangeAlertsKey = 'price_change_alerts';
  static const String _lastSyncedAtKey = 'last_synced_at';

  // Low Stock Threshold
  Future<int> getLowStockThreshold() async {
    return _prefs.getInt(_lowStockThresholdKey) ?? 10;
  }

  Future<void> setLowStockThreshold(int threshold) async {
    await _prefs.setInt(_lowStockThresholdKey, threshold);
  }

  // Auto Sync
  Future<bool> getAutoSync() async {
    return _prefs.getBool(_autoSyncKey) ?? true;
  }

  Future<void> setAutoSync(bool enabled) async {
    await _prefs.setBool(_autoSyncKey, enabled);
  }

  // Shop Logo URL
  Future<String?> getShopLogoUrl() async {
    return _prefs.getString(_shopLogoUrlKey);
  }

  Future<void> setShopLogoUrl(String? url) async {
    if (url == null) {
      await _prefs.remove(_shopLogoUrlKey);
    } else {
      await _prefs.setString(_shopLogoUrlKey, url);
    }
  }

  // Notification Preferences
  Future<bool> getNewSalesAlerts() async {
    return _prefs.getBool(_newSalesAlertsKey) ?? true;
  }

  Future<void> setNewSalesAlerts(bool enabled) async {
    await _prefs.setBool(_newSalesAlertsKey, enabled);
  }

  Future<bool> getLowStockAlerts() async {
    return _prefs.getBool(_lowStockAlertsKey) ?? true;
  }

  Future<void> setLowStockAlerts(bool enabled) async {
    await _prefs.setBool(_lowStockAlertsKey, enabled);
  }

  Future<bool> getSyncStatusAlerts() async {
    return _prefs.getBool(_syncStatusAlertsKey) ?? true;
  }

  Future<void> setSyncStatusAlerts(bool enabled) async {
    await _prefs.setBool(_syncStatusAlertsKey, enabled);
  }

  Future<bool> getPriceChangeAlerts() async {
    return _prefs.getBool(_priceChangeAlertsKey) ?? true;
  }

  Future<void> setPriceChangeAlerts(bool enabled) async {
    await _prefs.setBool(_priceChangeAlertsKey, enabled);
  }

  // Last Synced At
  Future<DateTime?> getLastSyncedAt() async {
    final timestamp = _prefs.getInt(_lastSyncedAtKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> setLastSyncedAt(DateTime dateTime) async {
    await _prefs.setInt(_lastSyncedAtKey, dateTime.millisecondsSinceEpoch);
  }
}

