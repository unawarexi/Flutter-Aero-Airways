import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_aero_airways/features/flight_management/domain/hive_model.dart';

class HiveInitializer {
  static bool _isInitialized = false;

  /// Initialize Hive with all required adapters and boxes
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();

      // Register all adapters
      await _registerAdapters();

      // Open all required boxes
      await _openBoxes();

      _isInitialized = true;
      debugPrint('Hive initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Register all Hive adapters
  static Future<void> _registerAdapters() async {
    // Register FavoriteFlight adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FavoriteFlightAdapter());
      debugPrint('FavoriteFlightAdapter registered');
    }

    // Add more adapters here as needed
    // Example:
    // if (!Hive.isAdapterRegistered(1)) {
    //   Hive.registerAdapter(AnotherModelAdapter());
    // }
  }

  /// Open all required Hive boxes
  static Future<void> _openBoxes() async {
    try {
      // Check if favorite flights box is already open before opening
      if (!Hive.isBoxOpen('favorite_flights')) {
        await Hive.openBox<FavoriteFlight>('favorite_flights');
        debugPrint('Favorite flights box opened');
      } else {
        debugPrint('Favorite flights box was already open');
      }

      // Add more boxes here as needed
      // Example:
      // if (!Hive.isBoxOpen('user_preferences')) {
      //   await Hive.openBox('user_preferences');
      // }
    } catch (e) {
      debugPrint('Error opening Hive boxes: $e');
      rethrow;
    }
  }

  /// Close all Hive boxes (call this when app is closing)
  static Future<void> closeAll() async {
    try {
      await Hive.close();
      _isInitialized = false;
      debugPrint('All Hive boxes closed');
    } catch (e) {
      debugPrint('Error closing Hive boxes: $e');
    }
  }

  /// Get a specific box
  static Box<T> getBox<T>(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not open. Make sure to open it first.');
    }
    return Hive.box<T>(boxName);
  }

  /// Check if Hive is initialized
  static bool get isInitialized => _isInitialized;

  /// Get app-specific storage directory info
  static String get storageInfo {
    try {
      if (Hive.isBoxOpen('favorite_flights')) {
        return 'Hive storage location: ${Hive.box('favorite_flights').path ?? 'Unknown'}';
      } else {
        return 'Hive storage location: Not available (box not open)';
      }
    } catch (e) {
      return 'Hive storage location: Error accessing path - $e';
    }
  }

  /// Clear all data from a specific box
  static Future<void> clearBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.clear();
        debugPrint('Box $boxName cleared');
      } else {
        debugPrint('Cannot clear box $boxName - box is not open');
      }
    } catch (e) {
      debugPrint('Error clearing box $boxName: $e');
      rethrow;
    }
  }

  /// Get statistics about a box
  static Map<String, dynamic> getBoxStats(String boxName) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        return {
          'name': boxName,
          'length': box.length,
          'isEmpty': box.isEmpty,
          'isNotEmpty': box.isNotEmpty,
          'keys': box.keys.toList(),
          'path': box.path,
        };
      } else {
        return {'name': boxName, 'error': 'Box is not open'};
      }
    } catch (e) {
      debugPrint('Error getting stats for box $boxName: $e');
      return {'error': e.toString()};
    }
  }

  /// Force close and reopen a box (useful for development/debugging)
  static Future<void> resetBox<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
        debugPrint('Box $boxName closed for reset');
      }

      await Hive.openBox<T>(boxName);
      debugPrint('Box $boxName reopened');
    } catch (e) {
      debugPrint('Error resetting box $boxName: $e');
      rethrow;
    }
  }
}
