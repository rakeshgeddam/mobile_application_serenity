import 'dart:io' show Platform;

import 'focus_handler_android.dart';
import 'focus_handler_ios.dart';

abstract class FocusHandler {
  Future<bool> startFocus({required String profile, required String title, required DateTime start, required DateTime end, required String eventId});
  Future<void> stopFocus();

  static FocusHandler instance() {
    try {
      if (Platform.isIOS) return FocusHandlerIOS();
    } catch (_) {}
    try {
      if (Platform.isAndroid) return FocusHandlerAndroid();
    } catch (_) {}
    // fallback to Android handler behavior if platform unknown
    return FocusHandlerAndroid();
  }
}
