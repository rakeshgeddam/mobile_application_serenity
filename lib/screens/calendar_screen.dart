import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'custom_calendar_widget.dart';
import 'event_list.dart';
import '../models/calendar_event.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import '../services/event_schedule_service.dart';
import '../platform/focus_handler.dart';
import 'dart:io' show Platform;

// Main calendar/schedule screen
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDate = DateTime.now();
  String _calendarMode = 'Month'; // "Month", "Week", "Agenda"
  // We'll use the global EventScheduleService to schedule and notify event starts
  VoidCallback? _startedListener;

  // Dummy map: date (yyyy-MM-dd) -> list of events; replace with a real model/provider
  final Map<String, List<EventModel>> eventMap = {
    "2024-10-18": [
      EventModel(
          title: "Deep Work: Focus Session",
          description: "Focus Session",
          startTime: TimeOfDay(hour: 9, minute: 0),
          endTime: TimeOfDay(hour: 11, minute: 0),
          icon: Icons.spa,
          color: Colors.teal[100]!),
    ],
    "2024-10-19": [
      EventModel(
          title: "Team Meeting",
          description: "Product Sync",
          startTime: TimeOfDay(hour: 14, minute: 0),
          endTime: TimeOfDay(hour: 15, minute: 0),
          icon: Icons.group,
          color: Colors.pink[100]!),
    ],
  };

  late Box<CalendarEvent> eventBox;

  // Gets events for a date
  List<EventModel> eventsForDate(DateTime date) {
    // First, gather events persisted in Hive for the given date
    final List<EventModel> results = [];
    for (final ce in eventBox.values) {
      if (ce.startTime.year == date.year && ce.startTime.month == date.month && ce.startTime.day == date.day) {
        results.add(_calendarEventToEventModel(ce));
      }
    }

    // Also include any in-memory demo events (keeps backwards compatibility)
    final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (eventMap.containsKey(key)) {
      results.addAll(eventMap[key]!.map((e) => e));
    }

    // Sort by start time
    results.sort((a, b) => a.startTime.hour != b.startTime.hour
        ? a.startTime.hour.compareTo(b.startTime.hour)
        : a.startTime.minute.compareTo(b.startTime.minute));

    return results;
  }

  @override
  void initState() {
    super.initState();
    eventBox = Hive.box<CalendarEvent>('calendarEvents');
    _requestDndPermission();
    // Listen for scheduled event starts from the central scheduler
    _startedListener = () {
      final id = EventScheduleService.instance.startedEventId.value;
      if (id != null) {
        CalendarEvent? found;
        for (final e in eventBox.values) {
          if (e.id == id) {
            found = e;
            break;
          }
        }
        if (found != null) {
          // handle platform specific focus behavior
          _handleEventStarted(found);
        }
      }
    };
    EventScheduleService.instance.startedEventId.addListener(_startedListener!);
  }

  @override
  void dispose() {
    if (_startedListener != null) EventScheduleService.instance.startedEventId.removeListener(_startedListener!);
    super.dispose();
  }

  // Called when an event has started (called from EventScheduleService listener)
  void _handleEventStarted(CalendarEvent ce) async {
    final profile = ce.desiredFocusProfile;
    final title = ce.title;
    final start = ce.startTime;
    final end = ce.endTime;

    final handler = FocusHandler.instance();
    final started = await handler.startFocus(profile: profile, title: title, start: start, end: end, eventId: ce.id);

    if (mounted) {
      if (Platform.isAndroid && started == false) {
        // DND permission not granted. Prompt the user to grant it.
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Do Not Disturb Permission Required'),
            content: const Text('This action needs permission to control Do Not Disturb. Open settings to grant the permission?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  // Try to open the DND policy settings. Use the plugin directly.
                  try {
                    final d = FlutterDnd as dynamic;
                    await d.gotoPolicySettings();
                  } catch (_) {}
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not enable DND for "$title" — permission required.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Focus action started for "${title}"')));
      }
    }

    if (Platform.isIOS && started && mounted) {
      // Inform the user that we donated a Siri activity and suggest adding a Shortcut
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Siri Shortcut Donated'),
          content: const Text(
            'We donated a Siri Shortcut for this event. To have iOS automatically enable a Focus mode for this event, open the Shortcuts app, find the donated action from this app, and create a Shortcut that sets the desired Focus mode at the scheduled time.'
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  // Scheduling is handled by EventScheduleService; this screen listens to its notifications.

  Future<void> _requestDndPermission() async {
    try {
      // Use dynamic invocation to avoid static API mismatch across versions.
      final d = FlutterDnd as dynamic;
      final access = await d.getNotificationPolicyAccessStatus();
      if (access == null || access == false) {
        // Some versions expose a method that returns void; call without await to be safe.
        try {
          d.gotoPolicySettings();
        } catch (_) {}
      }
    } catch (e) {
      // If running on a platform that doesn't support DND API or the package
      // doesn't expose the exact methods, silently ignore and continue.
    }
  }


// Deprecated top-level handler removed. Use _handleEventStarted in widget state.


// ScaffoldMessenger.of(context).showSnackBar(
//   SnackBar(content: Text("Please grant Do Not Disturb permission to enable silent mode during events."))
// );


  // Convert a Color to an 8-char ARGB hex string (alpha first).
  String _colorToHex(Color c) {
    final int v = c.value;
    final a = ((v >> 24) & 0xFF).toRadixString(16).padLeft(2, '0');
    final r = ((v >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');
    final g = ((v >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');
    final b = ((v >> 0) & 0xFF).toRadixString(16).padLeft(2, '0');
    return '$a$r$g$b';
  }

  void _addEventToDatabase(EventModel newEvent, {String desiredFocusProfile = ''}) {
    final calendarEvent = CalendarEvent(
      id: DateTime.now().toIso8601String(),
      title: newEvent.title,
      startTime: DateTime(
        _focusedDate.year,
        _focusedDate.month,
        _focusedDate.day,
        newEvent.startTime.hour,
        newEvent.startTime.minute,
      ),
      endTime: DateTime(
        _focusedDate.year,
        _focusedDate.month,
        _focusedDate.day,
        newEvent.endTime.hour,
        newEvent.endTime.minute,
      ),
      // store ARGB hex string
      color: _colorToHex(newEvent.color),
      type: 'Custom',
      notes: newEvent.description,
      recurringInfo: '',
      desiredFocusProfile: desiredFocusProfile,
      notificationInfo: null,
      isSynced: false,
    );

    eventBox.add(calendarEvent);
    setState(() {});
    EventScheduleService.instance.rescheduleNextNDays(3);
  }

  // Convert a stored CalendarEvent into the UI EventModel
  EventModel _calendarEventToEventModel(CalendarEvent ce) {
    // Parse color stored as hex string (without leading 0x)
    Color color;
    try {
      final parsed = int.parse(ce.color, radix: 16);
      if (ce.color.length <= 6) {
        color = Color(0xFF000000 | parsed);
      } else {
        color = Color(parsed);
      }
    } catch (_) {
      color = Colors.teal[100]!;
    }

    return EventModel(
      title: ce.title,
      description: ce.notes,
      startTime: TimeOfDay.fromDateTime(ce.startTime),
      endTime: TimeOfDay.fromDateTime(ce.endTime),
      icon: Icons.event,
      color: color,
      id: ce.id,
      desiredFocusProfile: ce.desiredFocusProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reserve bottom space to avoid overlap with the app-level nav bar.
    final double navReserve = MediaQuery.of(context).viewPadding.bottom + 80.0;

    // Build the main column content as `inner`.
    final inner = Padding(
      padding: EdgeInsets.only(top:15,bottom: navReserve),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Header: Mode toggle & month/year
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () {
                    setState(() {
                      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
                    });
                  },
                ),
                Text(
                  "${_focusedDate.month == 10 ? 'October' : _focusedDate.month}/${_focusedDate.year}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                  onPressed: () {
                    setState(() {
                      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 6.0,
                    children: [
                      for (var mode in ['Month', 'Week', 'Agenda'])
                        ChoiceChip(
                          label: Text(mode),
                          selected: _calendarMode == mode,
                          selectedColor: const Color(0xFF547E74),
                          backgroundColor: const Color(0xFFECEDED),
                          labelStyle: TextStyle(
                            color: _calendarMode == mode ? Colors.white : Colors.black87,
                          ),
                          onSelected: (_) => setState(() => _calendarMode = mode),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => setState(() => _focusedDate = DateTime.now()),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text("Today"),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Calendar Grid
            SizedBox(
              width: double.infinity,
              child: _calendarMode == 'Month'
                  ? CustomCalendarWidget(
                      focusedMonth: _focusedDate,
                      selectedDate: _focusedDate,
                      onDateSelected: (date) {
                        setState(() => _focusedDate = date);
                      },
                      eventMap: eventMap,
                    )
                  : _calendarMode == 'Week'
                      ? _buildWeekView()
                      : _buildAgendaView(),
            ),

            const SizedBox(height: 14),

            Text(
              "Today, ${_focusedDate.month}/${_focusedDate.day}/${_focusedDate.year}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(
              width: double.infinity,
              child: EventList(
                date: _focusedDate,
                events: eventsForDate(_focusedDate),
                onAddEvent: (EventModel newEvent) {
                  final events = eventsForDate(_focusedDate);
                  final isConflict = events.any((e) =>
                      (e.startTime.hour < newEvent.endTime.hour && newEvent.startTime.hour < e.endTime.hour));
                  if (isConflict) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Event conflict! Choose another time.")),
                    );
                    return;
                  }
                  setState(() {
                    final key = "${_focusedDate.year}-${_focusedDate.month.toString().padLeft(2, '0')}-${_focusedDate.day.toString().padLeft(2, '0')}";
                    eventMap.putIfAbsent(key, () => []);
                    eventMap[key]!.add(newEvent);
                  });
                  _addEventToDatabase(newEvent);
                },
                onEditEvent: (EventModel e) => _showEditEventDialog(context, e),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Stack(
        children: [
          inner,
          Positioned(
            right: 20,
            bottom: 100,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(202, 30, 201, 161),
              onPressed: () => _showAddEventDialog(context),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Show a dialog to collect event details and store them in Hive
  void _showAddEventDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    String title = '';
    String notes = '';
    // optional fields (collected below)
    DateTime date = _focusedDate;
    String desiredFocusProfile = '';
    TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 10, minute: 0);
    Color color = Colors.teal[100]!;
    bool isSynced = false;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Event'),
        content: StatefulBuilder(
          builder: (context, setStateSB) {
            return SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        onSaved: (v) => title = v?.trim() ?? '',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Notes'),
                        onSaved: (v) => notes = v?.trim() ?? '',
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Desired Focus Profile'),
                        onSaved: (v) => desiredFocusProfile = v?.trim() ?? '',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) setStateSB(() => date = picked);
                              },
                              child: Text('Date: ${date.month}/${date.day}/${date.year}'),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: start);
                                if (picked != null) setStateSB(() => start = picked);
                              },
                              child: Text('Start: ${start.format(context)}'),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: end);
                                if (picked != null) setStateSB(() => end = picked);
                              },
                              child: Text('End: ${end.format(context)}'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Simple color choices
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final c in [Colors.teal[100]!, Colors.pink[100]!, Colors.orange[200]!, Colors.blue[100]!])
                            GestureDetector(
                              onTap: () => setStateSB(() => color = c),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: c,
                                  border: Border.all(color: color == c ? Colors.black : Colors.transparent),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Synced'),
                          Checkbox(value: isSynced, onChanged: (v) => setStateSB(() => isSynced = v ?? false)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();

              // Ensure end is after start on the selected date
              final startDT = DateTime(date.year, date.month, date.day, start.hour, start.minute);
              final endDT = DateTime(date.year, date.month, date.day, end.hour, end.minute);
              if (!endDT.isAfter(startDT)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time must be after start time')));
                return;
              }

              final newEvent = EventModel(
                title: title,
                description: notes,
                startTime: start,
                endTime: end,
                icon: Icons.event,
                color: color,
              );

              // Add to DB
              _focusedDate = date;
              _addEventToDatabase(newEvent, desiredFocusProfile: desiredFocusProfile);

              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show dialog to view/edit an existing event. Finds the stored CalendarEvent by id.
  void _showEditEventDialog(BuildContext context, EventModel eventModel) async {
    if (eventModel.id == null) return; // cannot edit in-memory-only events

    // Find the Hive entry for this event
    final map = eventBox.toMap();
    MapEntry? foundEntry;
    map.entries.forEach((entry) {
      if (entry.value.id == eventModel.id) foundEntry = entry;
    });
    if (foundEntry == null) return;

    final int key = foundEntry!.key as int;
    final CalendarEvent ce = foundEntry!.value as CalendarEvent;

    final _formKey = GlobalKey<FormState>();

    String title = ce.title;
    String notes = ce.notes;
    DateTime date = ce.startTime;
    TimeOfDay start = TimeOfDay.fromDateTime(ce.startTime);
    TimeOfDay end = TimeOfDay.fromDateTime(ce.endTime);
    Color color;
    try {
      final parsed = int.parse(ce.color, radix: 16);
      if (ce.color.length <= 6) {
        color = Color(0xFF000000 | parsed);
      } else {
        color = Color(parsed);
      }
    } catch (_) {
      color = Colors.teal[100]!;
    }
    bool isSynced = ce.isSynced;
    String desiredFocusProfile = ce.desiredFocusProfile;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Event'),
        content: StatefulBuilder(
          builder: (context, setStateSB) {
            return SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: title,
                        decoration: const InputDecoration(labelText: 'Title'),
                        onSaved: (v) => title = v?.trim() ?? '',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      TextFormField(
                        initialValue: notes,
                        decoration: const InputDecoration(labelText: 'Notes'),
                        onSaved: (v) => notes = v?.trim() ?? '',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) setStateSB(() => date = picked);
                              },
                              child: Text('Date: ${date.month}/${date.day}/${date.year}'),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: start);
                                if (picked != null) setStateSB(() => start = picked);
                              },
                              child: Text('Start: ${start.format(context)}'),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: end);
                                if (picked != null) setStateSB(() => end = picked);
                              },
                              child: Text('End: ${end.format(context)}'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: desiredFocusProfile,
                        decoration: const InputDecoration(labelText: 'Desired Focus Profile'),
                        onSaved: (v) => desiredFocusProfile = v?.trim() ?? '',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final c in [Colors.teal[100]!, Colors.pink[100]!, Colors.orange[200]!, Colors.blue[100]!])
                            GestureDetector(
                              onTap: () => setStateSB(() => color = c),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: c,
                                  border: Border.all(color: color == c ? Colors.black : Colors.transparent),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Synced'),
                          Checkbox(value: isSynced, onChanged: (v) => setStateSB(() => isSynced = v ?? false)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();

              final startDT = DateTime(date.year, date.month, date.day, start.hour, start.minute);
              final endDT = DateTime(date.year, date.month, date.day, end.hour, end.minute);
              if (!endDT.isAfter(startDT)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time must be after start time')));
                return;
              }

              // Build updated CalendarEvent and replace in box at same key
              final updated = CalendarEvent(
                id: ce.id,
                title: title,
                startTime: startDT,
                endTime: endDT,
                color: _colorToHex(color),
                type: ce.type,
                notes: notes,
                recurringInfo: ce.recurringInfo,
                desiredFocusProfile: desiredFocusProfile,
                notificationInfo: ce.notificationInfo,
                isSynced: isSynced,
              );

              eventBox.put(key, updated);
              setState(() {});
              EventScheduleService.instance.rescheduleNextNDays(3);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final now = _focusedDate;
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = date.year == _focusedDate.year && 
                             date.month == _focusedDate.month && 
                             date.day == _focusedDate.day;
          
          // Check for events
          final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          final hasEvent = eventMap[key] != null && eventMap[key]!.isNotEmpty;
          // Also check Hive
          bool hasHiveEvent = false;
          for (final ce in eventBox.values) {
            if (ce.startTime.year == date.year && ce.startTime.month == date.month && ce.startTime.day == date.day) {
              hasHiveEvent = true;
              break;
            }
          }

          return GestureDetector(
            onTap: () => setState(() => _focusedDate = date),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF547E74) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['M','T','W','T','F','S','S'][index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (hasEvent || hasHiveEvent)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xFF547E74),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgendaView() {
    // Simple placeholder for Agenda, effectively just shows the list below which is already there.
    // But we can show a "Next 7 days" summary here if we wanted.
    // For now, let's just show a message that "Agenda shows events for selected day below".
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text("Select a day to view agenda below", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

// --- Event Model Class for demo ---
class EventModel {
  final String title;
  final String description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final IconData icon;
  final Color color;
  final String? id;
  final String? desiredFocusProfile;

  EventModel({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.icon,
    required this.color,
    this.id,
    this.desiredFocusProfile,
  });
}
