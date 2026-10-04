import 'package:flutter/services.dart';

class InstalledApp {
  final String name;
  final String packageName;
  final Uint8List? iconBytes;
  final bool isSystemApp;

  const InstalledApp({
    required this.name,
    required this.packageName,
    this.iconBytes,
    this.isSystemApp = false,
  });

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map) {
    return InstalledApp(
      name: map['appName'] as String? ?? 'Unknown App',
      packageName: map['packageName'] as String? ?? '',
      iconBytes: map['iconBytes'] as Uint8List?,
      isSystemApp: map['isSystemApp'] as bool? ?? false,
    );
  }
}

class BlockerChannel {
  static const _channel = MethodChannel('com.example.exam_seg_app/blocker');

  static Future<bool> requestPermissions() async {
    final granted = await _channel.invokeMethod<bool>('requestPermissions');
    return granted ?? false;
  }

  static Future<void> startLock({
    List<String> packages = const [],
    bool isPhoneWideBan = false,
  }) async {
    await _channel.invokeMethod('startLock', {
      'packages': packages,
      'isPhoneWideBan': isPhoneWideBan,
    });
  }

  static Future<void> stopLock() async {
    await _channel.invokeMethod('stopLock');
  }

  static Future<bool> createExitShortcut() async {
    try {
      final success = await _channel.invokeMethod<bool>('createShortcut');
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> exitApp() async {
    try {
      await _channel.invokeMethod('exitApp');
    } catch (_) {
      SystemNavigator.pop();
    }
  }

  static Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final List<dynamic>? result =
          await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result == null) return [];
      return result
          .map((item) => InstalledApp.fromMap(item as Map<dynamic, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
