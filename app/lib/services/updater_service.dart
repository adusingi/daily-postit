import 'dart:io';
import 'package:flutter/services.dart';

/// Service for checking app updates via Sparkle (macOS)
class UpdaterService {
  static const MethodChannel _channel = MethodChannel('com.dailypostit/updater');

  /// Check for updates manually
  static Future<void> checkForUpdates() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('checkForUpdates');
    } on MissingPluginException {
      // Not on macOS or plugin not available
    } catch (e) {
      // Silently fail
    }
  }

  /// Returns true if running on macOS with Sparkle support
  static bool get isSupported {
    return Platform.isMacOS;
  }
}
