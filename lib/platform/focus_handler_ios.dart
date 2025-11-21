import 'dart:async';
import 'package:flutter/services.dart';
import 'focus_handler.dart';

class FocusHandlerIOS implements FocusHandler {
  static const MethodChannel _channel = MethodChannel('rct.app/focus');

  @override
  Future<bool> startFocus({required String profile, required String title, required DateTime start, required DateTime end, required String eventId}) async {
    try {
      await _channel.invokeMethod('donateNSUserActivity', {
        'profile': profile,
        'title': title,
        'startMillis': start.millisecondsSinceEpoch,
        'endMillis': end.millisecondsSinceEpoch,
        'eventId': eventId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> stopFocus() async {
    // iOS donation doesn't force-stop system Focus; nothing to do here.
    return;
  }
}
