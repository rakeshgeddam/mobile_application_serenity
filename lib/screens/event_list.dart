import 'package:flutter/material.dart';
import '../screens/calendar_screen.dart'; // Import event model
import 'event_card.dart';

class EventList extends StatelessWidget {
  final DateTime date;
  final List<EventModel> events;
  final Function(EventModel) onAddEvent;
  final Function(EventModel)? onEditEvent;

  const EventList({
    super.key,
    required this.date,
    required this.events,
    required this.onAddEvent,
    this.onEditEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        events.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "No events yet. Tap '+' to add one!",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              )
            : Column(
                children: events
                  .map((event) => GestureDetector(
                      onTap: () => onEditEvent?.call(event),
                      child: EventCard(event: event),
                    ))
                  .toList(),
              ),
        // Add Event button (this could trigger a dialog)
        SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            side: const BorderSide(color: Color(0xFF547E74)),
          ),
          icon: Icon(Icons.add, color: Color(0xFF547E74)),
          label: Text("Add Event", style: TextStyle(color: Color(0xFF547E74))),
          onPressed: () async {
            // Show a simple dialog to add event (real app: use a form or modal)
            TimeOfDay? start = const TimeOfDay(hour: 10, minute: 0);
            TimeOfDay? end = const TimeOfDay(hour: 11, minute: 0);

            // Example pop-up, replace with your full form as needed
            final newEvent = EventModel(
              title: "New Event",
              description: "Type",
              startTime: start,
              endTime: end,
              icon: Icons.event,
              color: Colors.lightBlue[100]!,
            );
            onAddEvent(newEvent);
          },
        )
      ],
    );
  }
}
