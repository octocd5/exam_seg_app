import 'package:flutter/services.dart';

class BlockerChannel {
  static const _channel = MethodChannel('com.example.exam_seg_app/blocker');

  static Future<bool> requestPermissions() async {
    final granted = await _channel.invokeMethod<bool>('requestPermissions');
    return granted ?? false;
  }

  static Future<void> startLock() async {
    await _channel.invokeMethod('startLock');
  }

  static Future<void> stopLock() async {
    await _channel.invokeMethod('stopLock');
  }
}
