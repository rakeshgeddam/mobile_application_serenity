import 'dart:async';
import 'package:flutter/services.dart';

class FlutterDnd {
  static const int INTERRUPTION_FILTER_NONE = 1;
  static const int INTERRUPTION_FILTER_ALL = 0;

  static const MethodChannel _channel = MethodChannel('flutter_dnd');

  static Future<bool?> getNotificationPolicyAccessStatus() async {
    try {
      final res = await _channel.invokeMethod('getNotificationPolicyAccessStatus');
      if (res is bool) return res;
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> gotoPolicySettings() async {
    try {
      await _channel.invokeMethod('gotoPolicySettings');
    } catch (_) {}
  }

  static Future<void> setInterruptionFilter(int filter) async {
    try {
      await _channel.invokeMethod('setInterruptionFilter', {'filter': filter});
    } catch (_) {}
  }
}
