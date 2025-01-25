import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _lastUpdateKey = 'last_update_time';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Save data with timestamp
  Future<void> saveData(String key, Map<String, dynamic> data) async {
    final prefs = await _prefs;
    final timestamp = DateTime.now();
    
    final storageData = {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };

    await prefs.setString(key, json.encode(storageData));
    await prefs.setString(_lastUpdateKey, timestamp.toIso8601String());
  }

  // Get data if it's not expired
  Future<Map<String, dynamic>?> getData(String key) async {
    final prefs = await _prefs;
    final storedData = prefs.getString(key);

    if (storedData != null) {
      final data = json.decode(storedData);
      final timestamp = DateTime.parse(data['timestamp']);
      final now = DateTime.now();

      // Return data if it's less than 5 minutes old
      if (now.difference(timestamp) < const Duration(minutes: 5)) {
        return data['data'];
      }
    }
    return null;
  }

  // Get last update time
  Future<DateTime?> getLastUpdateTime() async {
    final prefs = await _prefs;
    final timestamp = prefs.getString(_lastUpdateKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  // Clear specific data
  Future<void> clearData(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  // Clear all stored data
  Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  // Check if data is stale
  Future<bool> isDataStale(String key) async {
    final prefs = await _prefs;
    final storedData = prefs.getString(key);

    if (storedData != null) {
      final data = json.decode(storedData);
      final timestamp = DateTime.parse(data['timestamp']);
      final now = DateTime.now();
      return now.difference(timestamp) >= const Duration(minutes: 5);
    }
    return true;
  }
}