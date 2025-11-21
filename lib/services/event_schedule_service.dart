import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/calendar_event.dart';

class EventScheduleService with ChangeNotifier {
  EventScheduleService._internal();
  static final EventScheduleService instance = EventScheduleService._internal();

  late Box _box; // scheduled events: key = event id, value = startMillis (int)

  // Notifiers exposed to UI: started event id and next scheduled DateTime
  final ValueNotifier<String?> startedEventId = ValueNotifier(null);
  final ValueNotifier<DateTime?> nextEventNotifier = ValueNotifier(null);

  final Map<String, Timer> _timers = {};

  Future<void> init({int daysToPreSchedule = 3}) async {
    _box = await Hive.openBox('scheduledEvents');
    await rescheduleNextNDays(daysToPreSchedule);
  }

  Future<void> rescheduleNextNDays(int n) async {
    // Scan calendarEvents and persist upcoming start times for the next N days
    final eventBox = Hive.box<CalendarEvent>('calendarEvents');
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day).add(Duration(days: n));

    // Build a new map of id->startMillis
    final Map<String, int> newSchedules = {};
    for (final ce in eventBox.values) {
      if (ce.startTime.isBefore(endDate) && !ce.endTime.isBefore(now)) {
        // We consider event if it ends in future and starts before endDate
        if (ce.startTime.isAfter(now)) {
          newSchedules[ce.id] = ce.startTime.millisecondsSinceEpoch;
        } else if (!ce.endTime.isBefore(now)) {
          // event is currently in progress — schedule immediate firing
          newSchedules[ce.id] = now.millisecondsSinceEpoch;
        }
      }
    }

    // Persist schedules
    await _box.clear();
    for (final e in newSchedules.entries) {
      await _box.put(e.key, e.value);
    }

    // Apply timers
    _applySchedules();
  }

  void _applySchedules() {
    // Cancel previous timers
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();

    final now = DateTime.now();
    DateTime? next;
    for (final key in _box.keys) {
      final millis = _box.get(key) as int?;
      if (millis == null) continue;
      final start = DateTime.fromMillisecondsSinceEpoch(millis);
      if (start.isBefore(now)) {
        // fire immediately on microtask
        Future.microtask(() => _onScheduledEvent(key));
      } else {
        final delay = start.difference(now);
        final timer = Timer(delay, () => _onScheduledEvent(key));
        _timers[key as String] = timer;
        if (next == null || start.isBefore(next)) next = start;
      }
    }

    nextEventNotifier.value = next;
  }

  void _onScheduledEvent(String id) {
    // notify listeners that this event started
    startedEventId.value = id;
    // remove from persisted box
    try {
      _box.delete(id);
    } catch (_) {}
    // recompute next
    _applySchedules();
  }

  Future<void> clearAll() async {
    for (final t in _timers.values) t.cancel();
    _timers.clear();
    startedEventId.value = null;
    nextEventNotifier.value = null;
    await _box.clear();
  }
}
