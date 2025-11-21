import 'dart:async';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'focus_handler.dart';

class FocusHandlerAndroid implements FocusHandler {
  Timer? _endTimer;

  @override
  Future<bool> startFocus({required String profile, required String title, required DateTime start, required DateTime end, required String eventId}) async {
    try {
      // Try dynamic invocation to be robust to API changes
      final d = FlutterDnd as dynamic;
      // Check whether the app has Notification Policy Access (DND) permission
      bool hasAccess = false;
      try {
        final access = await d.getNotificationPolicyAccessStatus();
        if (access is bool) hasAccess = access;
      } catch (_) {
        hasAccess = false;
      }

      if (!hasAccess) {
        // Permission not granted — do not attempt to change DND silently.
        return false;
      }

      // Attempt to set DND to "none" (silence interruptions)
      await d.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_NONE);
    } catch (e) {
      return false;
    }

    // schedule stop at end
    _endTimer?.cancel();
    final now = DateTime.now();
    if (end.isAfter(now)) {
      _endTimer = Timer(end.difference(now), () async {
        await stopFocus();
      });
    }
    return true;
  }

  @override
  Future<void> stopFocus() async {
    try {
      final d = FlutterDnd as dynamic;
      await d.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);
    } catch (e) {}
    _endTimer?.cancel();
    _endTimer = null;
  }
}
